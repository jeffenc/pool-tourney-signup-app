* [X]
* [ ]
* [ ]
* [ ]
* [ ]
* [ ]
* [ ] Dropdown for  **pool bars** , stored in DB.
* [X] **Tournament date** restricted to future only.
* [X] **Day-of-week validation** per bar.
* [X] **Admin table sortable** with DataTables.js (all but Delete column).

 With this setup:

* Signup page enforces **future-only** and  **bar-day match** .
* Admin can **sort columns** except delete.
* Pool bar is saved in DB + shown in admin/export.

Fri Aug 22 1:17AM

### ✅ What Changed

1. Added **Download CSV** and **Download Excel** buttons above the table.
2. Buttons link to `/export/csv` and `/export/excel`.
3. Table is still sortable using DataTables.js.

Fri Aug 22 2:15AM

### ✅ Summary of Fixes

1. **Alert now shows correct allowed day** (fixes “undefined”).
2. **Dropdown shows Pool Bar + Day** (e.g., “The Less Dead - Monday”).
3. **Date picker disables invalid dates** based on selected bar.
4. **Backend validation** prevents wrong date submissions.

Fri Aug 22 2:30AM

✅ Now:

* Admin page table shows columns in correct order.
* CSV export aligns perfectly with the table.
* Excel export aligns perfectly with the table.
* No more misalignment between **Pool Bar** and  **Tourney Date** .

✅ Second Commit (second-commit - fixed column issue for csv and excel downloads)

1. Fixed column issue with generating csv file from tourney entries (app.py)
2. Fixed column issue with generating excel file from tourney entries (app.py)
3. Fixed seeding of the database (seed.sh)
4. Added styling to admin page for better look & feel
5. Added shell script that downloads dependencies and runs the python application from terminal (run_app.sh)
   - flask
   - openpyxl
   - xlsxwriter
   - pandas
