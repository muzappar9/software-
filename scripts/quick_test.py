import sqlite3
import os

db_path = "assets/lawpack.db"
if os.path.exists(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 检查表
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in cursor.fetchall()]
    print(f"Tables: {tables}")
    
    # 检查文档数量
    if 'legal_documents' in tables:
        cursor.execute("SELECT COUNT(*) FROM legal_documents")
        doc_count = cursor.fetchone()[0]
        print(f"Documents: {doc_count}")
        
        cursor.execute("SELECT title FROM legal_documents LIMIT 3")
        docs = cursor.fetchall()
        print(f"Sample docs: {[doc[0] for doc in docs]}")
    
    # 检查条文数量
    if 'legal_articles' in tables:
        cursor.execute("SELECT COUNT(*) FROM legal_articles")
        article_count = cursor.fetchone()[0]
        print(f"Articles: {article_count}")
    
    # 文件大小
    file_size = os.path.getsize(db_path)
    print(f"DB Size: {file_size:,} bytes ({file_size/1024/1024:.1f} MB)")
    
    conn.close()
    print("✅ Database verification complete")
else:
    print("❌ Database not found")