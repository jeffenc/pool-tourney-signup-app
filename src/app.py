# Library Imports
from flask import Flask, make_response, render_template, request, redirect, url_for, Response, send_file
import sqlite3
from datetime import datetime
import csv
import io
import openpyxl
import xlsxwriter
import pandas as pd
from io import BytesIO, StringIO

# Initialize Flask app
app = Flask(__name__)

# --- Database Initialization ---
DB_PATH = "tourney.db"  # adjust to your DB path

# Database setup
def init_db():
    conn = sqlite3.connect("tourney.db")
    c = conn.cursor()
    c.execute("""
        CREATE TABLE IF NOT EXISTS signups (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            email TEXT NOT NULL,
            player_range INTEGER NOT NULL,
            pool_bar TEXT NOT NULL,
            signup_date TEXT NOT NULL,
            tourney_date TEXT DEFAULT NULL
        )
    """)
    # ensure "pool_bar" exists if upgrading
    try:
        c.execute("ALTER TABLE signups ADD COLUMN pool_bar TEXT")
    except:
        pass
    conn.commit()
    conn.close()


init_db()

# --- Home Page ---
@app.route("/")
def index():
    return render_template("index.html")

# --- Signup Page ---
@app.route("/signup", methods=["POST"])
def signup():
    first_name = request.form["first_name"]
    last_name = request.form["last_name"]
    email = request.form["email"]
    player_range = request.form["player_range"]
    pool_bar = request.form["pool_bar"]
    signup_date = request.form["signup_date"]

    # Backend validation
    bar_days = {
        "The Less Dead": 0,     # Monday
        "Propaganda": 3,        # Thursday
        "Ontario Bar": 4,       # Friday
        "Bushwick Icehouse": 6  # Sunday
    }

    dt = datetime.strptime(signup_date, "%Y-%m-%d")
    if dt.date() <= datetime.today().date():
        return "❌ Cannot select today or past dates", 400

    if bar_days[pool_bar] != dt.weekday():
        weekday_name = dt.strftime("%A")
        allowed_day_name = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"][bar_days[pool_bar]]
        return f"❌ {pool_bar} tourney must be on {allowed_day_name}", 400

    conn = sqlite3.connect("tourney.db")
    c = conn.cursor()
    c.execute("INSERT INTO signups (first_name, last_name, email, player_range, pool_bar, signup_date) VALUES (?, ?, ?, ?, ?, ?)",
              (first_name, last_name, email, player_range, pool_bar, signup_date))
    conn.commit()
    conn.close()

    return redirect(url_for("success"))


# --- Success Page ---
@app.route("/success")
def success():
    return render_template("success.html")

# --- Admin Page ---
@app.route("/admin", methods=["GET", "POST"])
def admin():
    conn = sqlite3.connect("tourney.db")
    c = conn.cursor()

   # query = "SELECT * FROM signups WHERE 1=1"
    query = "SELECT id, first_name, last_name, email, player_range, signup_date, pool_bar FROM signups WHERE 1=1"
    params = []

    player_range = None
    start_date = None
    end_date = None

    if request.method == "POST":
        player_range = request.form.get("player_range")
        start_date = request.form.get("start_date")
        end_date = request.form.get("end_date")

    if player_range and player_range != "all":
        query += " AND player_range=?"
        params.append(player_range)

    if start_date:
        query += " AND date(signup_date) >= date(?)"
        params.append(start_date)

    if end_date:
        query += " AND date(signup_date) <= date(?)"
        params.append(end_date)

    query += " ORDER BY signup_date DESC"
    c.execute(query, params)
    signups = c.fetchall()
    conn.close()

    return render_template("admin.html", signups=signups, 
                           player_range=player_range, start_date=start_date, end_date=end_date)

# --- Delete Signup ---
@app.route("/delete/<int:signup_id>", methods=["POST"])
def delete(signup_id):
    conn = sqlite3.connect("tourney.db")
    c = conn.cursor()
    c.execute("DELETE FROM signups WHERE id=?", (signup_id,))
    conn.commit()
    conn.close()
    return redirect(url_for("admin"))

# --- Export to CSV ---
@app.route("/export/csv")
def export_csv():
    conn = sqlite3.connect("tourney.db")
    c = conn.cursor()
    # Select explicitly in correct order
    # c.execute("SELECT id, first_name, last_name, email, player_range, pool_bar, signup_date, tourney_date FROM signups ORDER BY signup_date DESC")
    c.execute("SELECT id, first_name, last_name, email, player_range, signup_date, pool_bar FROM signups ORDER BY signup_date DESC")

    rows = c.fetchall()
    conn.close()

    output = io.StringIO()
    writer = csv.writer(output)
    headers = ["ID","First Name","Last Name","Email","Player Range","Tourney Date","Pool Bar"]
    writer.writerow(headers)
    writer.writerows(rows)

    response = Response(output.getvalue(), mimetype="text/csv")
    response.headers["Content-Disposition"] = "attachment; filename=signups.csv"
    return response

# --- Export to Excel ---
@app.route("/export/excel")
def export_excel():
    conn = sqlite3.connect("tourney.db")
    c = conn.cursor()
    # c.execute("SELECT id, first_name, last_name, email, player_range, pool_bar, signup_date, tourney_date FROM signups ORDER BY signup_date DESC")
    c.execute("SELECT id, first_name, last_name, email, player_range, signup_date, pool_bar FROM signups ORDER BY signup_date DESC")

    rows = c.fetchall()
    conn.close()

    output = io.BytesIO()
    workbook = xlsxwriter.Workbook(output, {'in_memory': True})
    worksheet = workbook.add_worksheet()

    headers = ["ID","First Name","Last Name","Email","Player Range","Tourney Date", "Pool Bar"]
    for col, header in enumerate(headers):
        worksheet.write(0, col, header)

    for row_num, row in enumerate(rows, 1):
        for col_num, value in enumerate(row):
            worksheet.write(row_num, col_num, value)

    workbook.close()
    output.seek(0)

    return send_file(output, as_attachment=True,
                     download_name="signups.xlsx",
                     mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

# old version of get_signups function
# def get_signups():
#     conn = sqlite3.connect(DB_PATH)
#     cursor = conn.cursor()
#     cursor.execute("SELECT * FROM signups")
#     rows = cursor.fetchall()
#     conn.close()
#     return rows

# New version of get_signups function
def get_signups():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    # Be explicit about which columns to select to match the DataFrame columns
    cursor.execute("SELECT id, first_name, last_name, email, player_range, pool_bar, signup_date FROM signups ORDER BY signup_date DESC")
    rows = cursor.fetchall()
    conn.close()
    return rows

# old version of download_csv function
# @app.route("/download_csv")
# def download_csv():
#     rows = get_signups()
#     df = pd.DataFrame(rows, columns=[
#         "ID", "First", "Last", "Email", "Player Range",
#         "Pool Bar", "Tourney Date"
#     ])

#     csv_buffer = StringIO()
#     df.to_csv(csv_buffer, index=False)

#     return send_file(
#         BytesIO(csv_buffer.getvalue().encode("utf-8")),
#         mimetype="text/csv",
#         as_attachment=True,
#         download_name="tournament_signups.csv"
#     )

# New version of download_csv function
@app.route("/download_csv")
def download_csv():
    rows = get_signups()
    df = pd.DataFrame(rows, columns=[
        "ID", "First Name", "Last Name", "Email", "Player Range",
        "Pool Bar", "Signup Date"
    ])

    csv_buffer = StringIO()
    df.to_csv(csv_buffer, index=False)

    return send_file(
        BytesIO(csv_buffer.getvalue().encode("utf-8")),
        mimetype="text/csv",
        as_attachment=True,
        download_name="tournament_signups.csv"
    )

# old version of download_excel function
# @app.route("/download_excel")
# def download_excel():
#     rows = get_signups()
#     df = pd.DataFrame(rows, columns=[
#         "ID", "First", "Last", "Email", "Player Range",
#          "Pool Bar", "Tourney Date"
#     ])

#     output = BytesIO()
#     with pd.ExcelWriter(output, engine="openpyxl") as writer:
#         df.to_excel(writer, index=False, sheet_name="Signups")

#     output.seek(0)
#     return send_file(
#         output,
#         mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
#         as_attachment=True,
#         download_name="tournament_signups.xlsx"
#     )

# new version of download_excel function
@app.route("/download_excel")
def download_excel():
    rows = get_signups()
    df = pd.DataFrame(rows, columns=[
        "ID", "First Name", "Last Name", "Email", "Player Range",
        "Pool Bar", "Signup Date"
    ])

    output = BytesIO()
    with pd.ExcelWriter(output, engine="openpyxl") as writer:
        df.to_excel(writer, index=False, sheet_name="Signups")

    output.seek(0)
    return send_file(
        output,
        mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        as_attachment=True,
        download_name="tournament_signups.xlsx"
    )

if __name__ == "__main__":
    app.run(debug=True)
