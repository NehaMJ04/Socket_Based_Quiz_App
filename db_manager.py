import sqlite3

DB_NAME = "quiz_data.db"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS leaderboard (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            score INTEGER NOT NULL,
            timestamp TEXT NOT NULL
        )
    """)

    conn.commit()
    conn.close()

def save_score(name, score, timestamp):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO leaderboard (name, score, timestamp) VALUES (?, ?, ?)",
        (name, score, timestamp)
    )

    conn.commit()
    conn.close()

def fetch_all_scores():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("SELECT name, score, timestamp FROM leaderboard")
    rows = cursor.fetchall()

    conn.close()
    return rows
