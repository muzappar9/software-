#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
法律文档解析器 - 将Word/PDF法律文件转换为数据库格式
Legal Document Parser - Convert Word/PDF legal files to database format
"""

import os
import sys
import sqlite3
import json
from pathlib import Path
from typing import List, Dict, Tuple
import re

# 尝试导入文档解析库
try:
    from docx import Document
    DOCX_AVAILABLE = True
except ImportError:
    DOCX_AVAILABLE = False
    print("⚠️  python-docx not available. Install with: pip install python-docx")

try:
    import PyPDF2
    PDF_AVAILABLE = True
except ImportError:
    PDF_AVAILABLE = False
    print("⚠️  PyPDF2 not available. Install with: pip install PyPDF2")

class LegalDocumentParser:
    """法律文档解析器"""
    
    def __init__(self, db_path: str):
        """初始化解析器
        
        Args:
            db_path: 数据库文件路径
        """
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """初始化数据库表结构"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 创建法律文档表
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS legal_documents (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                filename TEXT NOT NULL,
                file_type TEXT NOT NULL,
                content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # 创建法律条文表
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS legal_articles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                document_id INTEGER,
                chapter TEXT,
                article_number TEXT,
                article_title TEXT,
                content TEXT NOT NULL,
                keywords TEXT,
                FOREIGN KEY (document_id) REFERENCES legal_documents (id)
            )
        ''')
        
        # 创建全文搜索表
        cursor.execute('''
            CREATE VIRTUAL TABLE IF NOT EXISTS legal_search USING fts5(
                title, content, keywords,
                content=legal_articles,
                content_rowid=id
            )
        ''')
        
        conn.commit()
        conn.close()
        print("✅ 数据库表结构初始化完成")
    
    def extract_text_from_docx(self, file_path: str) -> str:
        """从Word文档提取文本"""
        if not DOCX_AVAILABLE:
            return "ERROR: python-docx not available"
        
        try:
            doc = Document(file_path)
            text = []
            for paragraph in doc.paragraphs:
                if paragraph.text.strip():
                    text.append(paragraph.text.strip())
            return '\n'.join(text)
        except Exception as e:
            return f"ERROR: Failed to extract from {file_path}: {str(e)}"
    
    def extract_text_from_pdf(self, file_path: str) -> str:
        """从PDF文档提取文本"""
        if not PDF_AVAILABLE:
            return "ERROR: PyPDF2 not available"
        
        try:
            with open(file_path, 'rb') as file:
                reader = PyPDF2.PdfReader(file)
                text = []
                for page in reader.pages:
                    page_text = page.extract_text()
                    if page_text.strip():
                        text.append(page_text.strip())
                return '\n'.join(text)
        except Exception as e:
            return f"ERROR: Failed to extract from {file_path}: {str(e)}"
    
    def parse_legal_articles(self, content: str, doc_title: str) -> List[Dict]:
        """解析法律条文"""
        articles = []
        
        # 匹配法律条文的正则表达式
        patterns = [
            r'第([一二三四五六七八九十百千万\d]+)条\s*(.+?)(?=第[一二三四五六七八九十百千万\d]+条|$)',
            r'第([一二三四五六七八九十百千万\d]+)章\s*(.+?)(?=第[一二三四五六七八九十百千万\d]+章|第[一二三四五六七八九十百千万\d]+条|$)',
            r'([一二三四五六七八九十百千万\d]+)、\s*(.+?)(?=[一二三四五六七八九十百千万\d]+、|$)',
        ]
        
        for pattern in patterns:
            matches = re.finditer(pattern, content, re.DOTALL | re.MULTILINE)
            for match in matches:
                article_num = match.group(1)
                article_content = match.group(2).strip()
                
                if len(article_content) > 10:  # 过滤过短的内容
                    # 提取关键词
                    keywords = self.extract_keywords(article_content)
                    
                    articles.append({
                        'article_number': article_num,
                        'content': article_content,
                        'keywords': ', '.join(keywords),
                        'chapter': self.detect_chapter(article_content)
                    })
        
        # 如果没有找到结构化条文，将整个文档作为一个条目
        if not articles:
            keywords = self.extract_keywords(content)
            articles.append({
                'article_number': '全文',
                'content': content,
                'keywords': ', '.join(keywords),
                'chapter': doc_title
            })
        
        return articles
    
    def extract_keywords(self, text: str) -> List[str]:
        """提取关键词"""
        # 法律相关关键词
        legal_keywords = [
            '合同', '协议', '违约', '赔偿', '责任', '义务', '权利', '法律',
            '婚姻', '离婚', '财产', '抚养', '继承', '遗产',
            '劳动', '工伤', '社保', '工资', '辞职', '解雇',
            '交通', '事故', '保险', '理赔', '驾驶', '违章',
            '消费', '权益', '欺诈', '退货', '质量', '服务',
            '行政', '处罚', '程序', '申诉', '复议', '诉讼',
            '民事', '刑事', '证据', '审判', '执行', '仲裁'
        ]
        
        found_keywords = []
        for keyword in legal_keywords:
            if keyword in text:
                found_keywords.append(keyword)
        
        return found_keywords[:10]  # 限制关键词数量
    
    def detect_chapter(self, content: str) -> str:
        """检测章节信息"""
        chapter_patterns = [
            r'第([一二三四五六七八九十百千万\d]+)编',
            r'第([一二三四五六七八九十百千万\d]+)章',
            r'第([一二三四五六七八九十百千万\d]+)节',
        ]
        
        for pattern in chapter_patterns:
            match = re.search(pattern, content)
            if match:
                return f"第{match.group(1)}章"
        
        return "通用条款"
    
    def process_document(self, file_path: str) -> bool:
        """处理单个文档"""
        file_path = Path(file_path)
        
        if not file_path.exists():
            print(f"❌ 文件不存在: {file_path}")
            return False
        
        print(f"📄 正在处理: {file_path.name}")
        
        # 提取文本内容
        if file_path.suffix.lower() == '.docx':
            content = self.extract_text_from_docx(str(file_path))
        elif file_path.suffix.lower() == '.pdf':
            content = self.extract_text_from_pdf(str(file_path))
        else:
            print(f"⚠️  不支持的文件格式: {file_path.suffix}")
            return False
        
        if content.startswith("ERROR:"):
            print(f"❌ 文档解析失败: {content}")
            return False
        
        # 获取文档标题
        title = file_path.stem
        
        # 保存到数据库
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 插入文档记录
        cursor.execute('''
            INSERT INTO legal_documents (title, filename, file_type, content)
            VALUES (?, ?, ?, ?)
        ''', (title, file_path.name, file_path.suffix, content))
        
        document_id = cursor.lastrowid
        
        # 解析并插入法律条文
        articles = self.parse_legal_articles(content, title)
        
        for article in articles:
            cursor.execute('''
                INSERT INTO legal_articles 
                (document_id, chapter, article_number, content, keywords)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                document_id,
                article['chapter'],
                article['article_number'],
                article['content'],
                article['keywords']
            ))
            
            # 插入全文搜索表
            cursor.execute('''
                INSERT INTO legal_search (title, content, keywords)
                VALUES (?, ?, ?)
            ''', (title, article['content'], article['keywords']))
        
        conn.commit()
        conn.close()
        
        print(f"✅ 已处理 {title}: {len(articles)} 个条文")
        return True
    
    def process_directory(self, directory_path: str):
        """处理目录中的所有文档"""
        directory = Path(directory_path)
        
        if not directory.exists():
            print(f"❌ 目录不存在: {directory}")
            return
        
        print(f"📁 开始处理目录: {directory}")
        
        # 支持的文件类型
        supported_extensions = ['.docx', '.pdf']
        
        processed_count = 0
        failed_count = 0
        
        for file_path in directory.iterdir():
            if file_path.is_file() and file_path.suffix.lower() in supported_extensions:
                if self.process_document(file_path):
                    processed_count += 1
                else:
                    failed_count += 1
        
        print(f"\n📊 处理完成统计:")
        print(f"✅ 成功处理: {processed_count} 个文件")
        print(f"❌ 处理失败: {failed_count} 个文件")
        
        # 显示数据库统计
        self.show_database_stats()
    
    def show_database_stats(self):
        """显示数据库统计信息"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 文档统计
        cursor.execute("SELECT COUNT(*) FROM legal_documents")
        doc_count = cursor.fetchone()[0]
        
        # 条文统计
        cursor.execute("SELECT COUNT(*) FROM legal_articles")
        article_count = cursor.fetchone()[0]
        
        # 按文档统计条文数量
        cursor.execute('''
            SELECT d.title, COUNT(a.id) as article_count
            FROM legal_documents d
            LEFT JOIN legal_articles a ON d.id = a.document_id
            GROUP BY d.id, d.title
            ORDER BY article_count DESC
        ''')
        
        doc_stats = cursor.fetchall()
        
        conn.close()
        
        print(f"\n📊 数据库统计:")
        print(f"📄 总文档数: {doc_count}")
        print(f"📝 总条文数: {article_count}")
        print(f"\n📋 各文档条文统计:")
        
        for title, count in doc_stats:
            print(f"  • {title}: {count} 条")

def main():
    """主函数"""
    print("🚀 法律文档解析器启动")
    
    # 设置路径
    current_dir = Path.cwd()
    legal_docs_dir = current_dir / "assets" / "legal-data" / "laws"
    db_path = current_dir / "assets" / "lawpack.db"
    
    print(f"📁 法律文档目录: {legal_docs_dir}")
    print(f"🗃️  数据库路径: {db_path}")
    
    # 检查依赖
    missing_deps = []
    if not DOCX_AVAILABLE:
        missing_deps.append("python-docx")
    if not PDF_AVAILABLE:
        missing_deps.append("PyPDF2")
    
    if missing_deps:
        print(f"\n⚠️  缺少依赖库: {', '.join(missing_deps)}")
        print("请运行以下命令安装:")
        print(f"pip install {' '.join(missing_deps)}")
        return False
    
    # 创建解析器并处理文档
    parser = LegalDocumentParser(str(db_path))
    parser.process_directory(str(legal_docs_dir))
    
    print("\n🎉 法律文档解析完成！")
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)