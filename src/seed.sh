
# #!/usr/bin/env bash

# # File: seed.sh
# # This script seeds a SQLite database named 'tourney.db' with mock pool tournament signup data.

# DB="tourney.db"

# # Create the signups table if it doesn't exist.
# # Using 'EOF' as the heredoc delimiter for the SQL command.
# sqlite3 $DB <<EOF
# CREATE TABLE IF NOT EXISTS signups (
#     id INTEGER PRIMARY KEY AUTOINCREMENT,
#     first TEXT,
#     last TEXT,
#     email TEXT,
#     player_range INTEGER,
#     pool_bar TEXT,
#     tourney_date TEXT, 
#     signup_date TEXT
# );
# EOF

# # Helper: get next weekday (1=Mon … 7=Sun)
# # This function calculates the date of the next specified weekday.
# # It uses different 'date' command syntax for GNU (Linux) and BSD (macOS) to ensure cross-platform compatibility.
# get_next_weekday() {
#   local target_day=$1
#   local offset=1
#   while true; do
#     # Check for GNU date --version to differentiate between Linux and macOS
#     if date --version >/dev/null 2>&1; then
#       # GNU date (Linux)
#       candidate_day=$(date -d "+$offset day" +%u)
#       date_str=$(date -d "+$offset day" +%Y-%m-%d)
#     else
#       # BSD date (macOS)
#       candidate_day=$(date -v+${offset}d +%u)
#       date_str=$(date -v+${offset}d +%Y-%m-%d)
#     fi

#     if [[ "$candidate_day" -eq "$target_day" ]]; then
#       echo "$date_str"
#       return
#     fi
#     offset=$((offset+1))
#   done
# }

# # Helper: map bar name to a specific weekday number.
# bar_to_weekday() {
#   case "$1" in
#     ("The Less Dead") echo 1 ;;       # Monday
#     ("Propaganda") echo 4 ;;          # Thursday
#     ("Bushwick Icehouse") echo 7 ;;   # Sunday
#     ("Ontario Bar") echo 5 ;;         # Friday
#   esac
# }

# # Arrays of data to use for seeding.
# FIRST_NAMES=("Alex" "Sam" "Taylor" "Jordan" "Riley" "Morgan" "Casey" "Jamie" "Cameron" "Drew")
# LAST_NAMES=("Smith" "Johnson" "Williams" "Brown" "Jones" "Miller" "Davis" "Garcia" "Rodriguez" "Martinez")
# BARS=("The Less Dead" "Propaganda" "Bushwick Icehouse" "Ontario Bar")

# # Loop to generate and insert 20 mock signups.
# for i in {1..20}; do
#   # Fix 1: Use a simple bash array indexing to get a random element instead of 'shuf'.
#   # This makes the script compatible with macOS.
#   FIRST=${FIRST_NAMES[$RANDOM % ${#FIRST_NAMES[@]}]}
#   LAST=${LAST_NAMES[$RANDOM % ${#LAST_NAMES[@]}]}
  
#   # Generate email and player range.
#   EMAIL="$(echo "$FIRST" | tr '[:upper:]' '[:lower:]').$(echo "$LAST" | tr '[:upper:]' '[:lower:]')$i@example.com"
#   # Player range is now a simple array and a random element is selected.
#   PLAYER_RANGES=(8 16 32)
#   PLAYER_RANGE=${PLAYER_RANGES[$RANDOM % ${#PLAYER_RANGES[@]}]}

#   # Select a random bar and calculate the tournament date.
#   BAR=${BARS[$RANDOM % ${#BARS[@]}]}
#   TARGET_DAY=$(bar_to_weekday "$BAR")
#   TOURNEY_DATE=$(get_next_weekday $TARGET_DAY)

#   # Get the current date for the signup date.
#   SIGNUP_DATE=$(date +%Y-%m-%d)

#   # Fix 2: Use single quotes (') around string values in the SQL INSERT statement.
#   # This prevents shell variable expansion issues with spaces or special characters.
#   # Fix 3: Reordered the values to match the column order in the CREATE TABLE statement.
#   sqlite3 $DB <<EOF
# INSERT INTO signups (first, last, email, player_range, signup_date, pool_bar, tourney_date)
# VALUES ('$FIRST', '$LAST', '$EMAIL', $PLAYER_RANGE, '$SIGNUP_DATE', $BAR', '$TOURNEY_DATE');
# EOF
# done

# echo "✅ Seeded 20 mock signups into $DB with correct days + future dates"



#!/usr/bin/env bash

# File: seed.sh
# This script seeds a SQLite database named 'tourney.db' with mock pool tournament signup data.

DB="tourney.db"

# Create the signups table if it doesn't exist.
# Using 'EOF' as the heredoc delimiter for the SQL command.
sqlite3 $DB <<EOF
CREATE TABLE IF NOT EXISTS signups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    player_range INTEGER,
    pool_bar TEXT,
    signup_date TEXT,
    tourney_date TEXT
);
EOF

# Helper: get next weekday (1=Mon … 7=Sun)
# This function calculates the date of the next specified weekday.
# It uses different 'date' command syntax for GNU (Linux) and BSD (macOS) to ensure cross-platform compatibility.
get_next_weekday() {
  local target_day=$1
  local offset=1
  while true; do
    # Check for GNU date --version to differentiate between Linux and macOS
    if date --version >/dev/null 2>&1; then
      # GNU date (Linux)
      candidate_day=$(date -d "+$offset day" +%u)
      date_str=$(date -d "+$offset day" +%Y-%m-%d)
    else
      # BSD date (macOS)
      candidate_day=$(date -v+${offset}d +%u)
      date_str=$(date -v+${offset}d +%Y-%m-%d)
    fi

    if [[ "$candidate_day" -eq "$target_day" ]]; then
      echo "$date_str"
      return
    fi
    offset=$((offset+1))
  done
}

# Helper: map bar name to a specific weekday number.
bar_to_weekday() {
  case "$1" in
    ("The Less Dead") echo 1 ;;       # Monday
    ("Propaganda") echo 4 ;;          # Thursday
    ("Bushwick Icehouse") echo 7 ;;   # Sunday
    ("Ontario Bar") echo 5 ;;         # Friday
  esac
}

# Arrays of data to use for seeding.
FIRST_NAMES=("Alex" "Sam" "Taylor" "Jordan" "Riley" "Morgan" "Casey" "Jamie" "Cameron" "Drew")
LAST_NAMES=("Smith" "Johnson" "Williams" "Brown" "Jones" "Miller" "Davis" "Garcia" "Rodriguez" "Martinez")
BARS=("The Less Dead" "Propaganda" "Bushwick Icehouse" "Ontario Bar")

# Loop to generate and insert 20 mock signups.
for i in {1..20}; do
  # Fix 1: Use a simple bash array indexing to get a random element instead of 'shuf'.
  # This makes the script compatible with macOS.
  FIRST_NAME=${FIRST_NAMES[$RANDOM % ${#FIRST_NAMES[@]}]}
  LAST_NAME=${LAST_NAMES[$RANDOM % ${#LAST_NAMES[@]}]}
  
  # Generate email and player range.
  EMAIL="$(echo "$FIRST" | tr '[:upper:]' '[:lower:]').$(echo "$LAST" | tr '[:upper:]' '[:lower:]')$i@example.com"
  # Player range is now a simple array and a random element is selected.
  PLAYER_RANGES=(8 16 32)
  PLAYER_RANGE=${PLAYER_RANGES[$RANDOM % ${#PLAYER_RANGES[@]}]}

  # Select a random bar and calculate the tournament date.
  BAR=${BARS[$RANDOM % ${#BARS[@]}]}
  TARGET_DAY=$(bar_to_weekday "$BAR")
  TOURNEY_DATE=$(get_next_weekday $TARGET_DAY)

  # Get the current date for the signup date.
  SIGNUP_DATE=$(date +%Y-%m-%d)

  # Fix 2: Use a single, reliable printf command to generate the SQL statement and pipe it to sqlite3.
  # This avoids variable expansion issues with here documents.
  printf "INSERT INTO signups (first_name, last_name, email, player_range, pool_bar, signup_date, tourney_date) VALUES ('%s', '%s', '%s', %d, '%s', '%s', '%s');" \
    "$FIRST_NAME" \
    "$LAST_NAME" \
    "$EMAIL" \
    "$PLAYER_RANGE" \
    "$BAR" \
    "$SIGNUP_DATE" \
    "$TOURNEY_DATE" | sqlite3 "$DB"
done

echo "✅ Seeded 20 mock signups into $DB with correct days + future dates"

