#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
LawPack数据库测试脚本 - 测试法律条文搜索功能
LawPack Database Test Script - Test legal article search functionality
"""

import sqlite3
import json
from pathlib import Path

class LawPackTester:
    """LawPack数据库测试器"""
    
    def __init__(self, db_path: str):
        self.db_path = db_path
        
    def test_database_connection(self):
        """测试数据库连接"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM legal_documents")
            count = cursor.fetchone()[0]
            conn.close()
            print(f"✅ 数据库连接成功，文档数量: {count}")
            return True
        except Exception as e:
            print(f"❌ 数据库连接失败: {e}")
            return False
    
    def show_database_structure(self):
        """显示数据库结构"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        print("\n📊 数据库结构分析:")
        
        # 表结构
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = cursor.fetchall()
        print(f"📋 数据库表: {[table[0] for table in tables]}")
        
        # 文档统计
        cursor.execute("SELECT COUNT(*) FROM legal_documents")
        doc_count = cursor.fetchone()[0]
        print(f"📄 文档数量: {doc_count}")
        
        # 条文统计
        cursor.execute("SELECT COUNT(*) FROM legal_articles")
        article_count = cursor.fetchone()[0]
        print(f"📝 条文数量: {article_count}")
        
        # 搜索表统计
        cursor.execute("SELECT COUNT(*) FROM legal_search")
        search_count = cursor.fetchone()[0]
        print(f"🔍 搜索索引: {search_count}")
        
        conn.close()
    
    def test_document_queries(self):
        """测试文档查询功能"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        print("\n📄 文档查询测试:")
        
        # 查询所有文档
        cursor.execute("SELECT id, title, filename, LENGTH(content) as content_length FROM legal_documents")
        documents = cursor.fetchall()
        
        for doc_id, title, filename, content_length in documents:
            print(f"  • {title} ({filename}) - {content_length:,} 字符")
        
        conn.close()
    
    def test_article_search(self):
        """测试条文搜索功能"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        print("\n🔍 条文搜索测试:")
        
        # 测试用例
        test_cases = [
            "离婚",
            "劳动合同", 
            "交通事故",
            "消费者权益",
            "工伤赔偿",
            "民事诉讼",
            "行政处罚",
            "合同违约"
        ]
        
        for keyword in test_cases:
            print(f"\n🔎 搜索关键词: '{keyword}'")
            
            # 使用FTS5全文搜索
            cursor.execute('''
                SELECT title, content, keywords 
                FROM legal_search 
                WHERE legal_search MATCH ? 
                LIMIT 3
            ''', (keyword,))
            
            results = cursor.fetchall()
            
            if results:
                print(f"  找到 {len(results)} 条相关条文:")
                for i, (title, content, keywords) in enumerate(results, 1):
                    content_preview = content[:100] + "..." if len(content) > 100 else content
                    print(f"    {i}. {title}")
                    print(f"       内容: {content_preview}")
                    print(f"       关键词: {keywords}")
            else:
                print("  ❌ 未找到相关条文")
        
        conn.close()
    
    def test_specific_legal_queries(self):
        """测试具体法律问题查询"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        print("\n⚖️ 具体法律问题测试:")
        
        legal_questions = [
            {
                "question": "夫妻离婚后财产如何分割？",
                "keywords": ["离婚", "财产", "分割"]
            },
            {
                "question": "员工被无故解雇怎么办？",
                "keywords": ["解雇", "劳动", "合同"]
            },
            {
                "question": "交通事故责任如何认定？",
                "keywords": ["交通", "事故", "责任"]
            },
            {
                "question": "消费者买到假货如何维权？",
                "keywords": ["消费者", "假货", "维权"]
            }
        ]
        
        for case in legal_questions:
            print(f"\n❓ 问题: {case['question']}")
            
            # 构建搜索查询
            search_query = " OR ".join(case['keywords'])
            
            cursor.execute('''
                SELECT d.title, a.article_number, a.content, a.keywords
                FROM legal_articles a
                JOIN legal_documents d ON a.document_id = d.id
                WHERE a.content LIKE ? OR a.keywords LIKE ?
                LIMIT 2
            ''', (f"%{case['keywords'][0]}%", f"%{case['keywords'][0]}%"))
            
            results = cursor.fetchall()
            
            if results:
                print(f"  📚 找到 {len(results)} 条相关法条:")
                for doc_title, article_num, content, keywords in results:
                    content_preview = content[:200] + "..." if len(content) > 200 else content
                    print(f"    📖 {doc_title} - 第{article_num}条")
                    print(f"       {content_preview}")
                    print(f"       关键词: {keywords}")
            else:
                print("  ❌ 未找到相关法条")
        
        conn.close()
    
    def test_performance(self):
        """测试查询性能"""
        import time
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        print("\n⚡ 性能测试:")
        
        # 测试普通查询性能
        start_time = time.time()
        cursor.execute("SELECT COUNT(*) FROM legal_articles WHERE content LIKE '%合同%'")
        result = cursor.fetchone()[0]
        normal_time = time.time() - start_time
        print(f"  普通LIKE查询: {result} 条结果，耗时 {normal_time:.3f} 秒")
        
        # 测试FTS5查询性能
        start_time = time.time()
        cursor.execute("SELECT COUNT(*) FROM legal_search WHERE legal_search MATCH '合同'")
        result = cursor.fetchone()[0]
        fts_time = time.time() - start_time
        print(f"  FTS5全文搜索: {result} 条结果，耗时 {fts_time:.3f} 秒")
        
        if normal_time > 0:
            speedup = normal_time / fts_time if fts_time > 0 else float('inf')
            print(f"  🚀 FTS5查询速度提升: {speedup:.1f}x")
        
        conn.close()
    
    def export_sample_data(self):
        """导出样本数据用于App集成测试"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        print("\n📤 导出样本数据:")
        
        # 导出每个文档的前5条条文
        cursor.execute('''
            SELECT d.title, a.article_number, a.content, a.keywords
            FROM legal_articles a
            JOIN legal_documents d ON a.document_id = d.id
            WHERE a.id <= 5
            ORDER BY d.id, a.id
        ''')
        
        sample_data = cursor.fetchall()
        
        # 保存为JSON文件
        sample_file = Path.cwd() / "assets" / "legal-data" / "sample_articles.json"
        sample_file.parent.mkdir(parents=True, exist_ok=True)
        
        sample_json = []
        for title, article_num, content, keywords in sample_data:
            sample_json.append({
                "document": title,
                "article": article_num,
                "content": content,
                "keywords": keywords.split(", ") if keywords else []
            })
        
        with open(sample_file, 'w', encoding='utf-8') as f:
            json.dump(sample_json, f, ensure_ascii=False, indent=2)
        
        print(f"  ✅ 样本数据已导出到: {sample_file}")
        print(f"  📊 样本条文数量: {len(sample_json)}")
        
        conn.close()
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🧪 开始LawPack数据库全面测试")
        print("=" * 50)
        
        if not self.test_database_connection():
            return False
        
        self.show_database_structure()
        self.test_document_queries()
        self.test_article_search()
        self.test_specific_legal_queries()
        self.test_performance()
        self.export_sample_data()
        
        print("\n" + "=" * 50)
        print("🎉 所有测试完成！")
        return True

def main():
    """主函数"""
    db_path = Path.cwd() / "assets" / "lawpack.db"
    
    if not db_path.exists():
        print(f"❌ 数据库文件不存在: {db_path}")
        return False
    
    tester = LawPackTester(str(db_path))
    return tester.run_all_tests()

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)