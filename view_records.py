from db_manager import fetch_all_scores

records = fetch_all_scores()

print("\n--- Quiz Records ---")
for r in records:
    print(f"Name: {r[0]} | Score: {r[1]} | Time: {r[2]}")
