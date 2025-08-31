import sqlite3
import os

def test_database():
    db_path = 'assets/lawpack.db'
    if not os.path.exists(db_path):
        print(f"❌ 数据库文件不存在: {db_path}")
        return
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # 检查表结构
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = [row[0] for row in cursor.fetchall()]
        print(f"✅ 数据库表: {tables}")
        
        # 检查chunks表内容
        if 'chunks' in tables:
            cursor.execute("SELECT COUNT(*) FROM chunks")
            count = cursor.fetchone()[0]
            print(f"✅ 法律条文数量: {count}")
            
            # 查看示例数据
            cursor.execute("SELECT chunk_text FROM chunks LIMIT 3")
            samples = cursor.fetchall()
            print("✅ 示例法律条文:")
            for i, sample in enumerate(samples, 1):
                print(f"  {i}. {sample[0][:100]}...")
        
        conn.close()
        print("✅ 数据库测试完成")
        
    except Exception as e:
        print(f"❌ 数据库测试失败: {e}")

if __name__ == "__main__":
    test_database()