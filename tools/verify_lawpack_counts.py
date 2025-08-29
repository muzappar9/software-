import sqlite3, sys
db = sys.argv[1] if len(sys.argv)>1 else 'assets/lawpack.db'
con = sqlite3.connect(db)
cur = con.cursor()
chunks = cur.execute('select count(*) from chunks').fetchone()[0]
articles = cur.execute('select count(*) from articles').fetchone()[0]
print(f"chunks={chunks}, articles={articles}")