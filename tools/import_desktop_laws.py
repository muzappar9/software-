#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
导入桌面法律文件到LawPack数据库的工具
从 C:\Users\26581\Desktop\法律资料 导入8个法律文件
"""

import os
import sqlite3
import re
from pathlib import Path
import docx
import PyPDF2

def extract_text_from_docx(file_path):
    """从DOCX文件提取文本"""
    try:
        doc = docx.Document(file_path)
        text = []
        for paragraph in doc.paragraphs:
            if paragraph.text.strip():
                text.append(paragraph.text.strip())
        return '\n'.join(text)
    except Exception as e:
        print(f"Error reading DOCX {file_path}: {e}")
        return ""

def extract_text_from_pdf(file_path):
    """从PDF文件提取文本"""
    try:
        with open(file_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            text = []
            for page in reader.pages:
                text.append(page.extract_text())
        return '\n'.join(text)
    except Exception as e:
        print(f"Error reading PDF {file_path}: {e}")
        return ""

def split_into_chunks(text, law_name):
    """将法律文本分割为条文块"""
    # 匹配法条格式：第X条、第X章、第X节等
    patterns = [
        r'(?=第\s*[一二三四五六七八九十百千万零〇0-9]+\s*条)',
        r'(?=第\s*[一二三四五六七八九十百千万零〇0-9]+\s*章)',
        r'(?=第\s*[一二三四五六七八九十百千万零〇0-9]+\s*节)',
    ]
    
    chunks = []
    for pattern in patterns:
        parts = re.split(pattern, text)
        if len(parts) > 1:
            # 使用第一个有效的分割模式
            for i, part in enumerate(parts[1:], 1):  # 跳过第一个空白部分
                if part.strip():
                    chunks.append({
                        'content': part.strip()[:2000],  # 限制长度
                        'article_id': f"{law_name}_chunk_{i}",
                        'law_name': law_name
                    })
            break
    
    # 如果没有找到条文分割，按段落分割
    if not chunks:
        paragraphs = text.split('\n')
        for i, para in enumerate(paragraphs):
            if para.strip() and len(para.strip()) > 20:
                chunks.append({
                    'content': para.strip()[:2000],
                    'article_id': f"{law_name}_para_{i}",
                    'law_name': law_name
                })
    
    return chunks

def import_law_files():
    """导入桌面上的8个法律文件"""
    
    # 桌面法律文件路径
    desktop_law_path = r"C:\Users\26581\Desktop\法律资料"
    
    # 法律文件列表
    law_files = [
        ("中华人民共和国道路交通安全法.docx", "道路交通安全法"),
        ("中华人民民法典.docx", "民法典"),
        ("中国人民共和国劳动合同法.docx", "劳动合同法"),
        ("中国人民共和国劳动法.docx", "劳动法"),
        ("中国人民共和国民事诉讼法.pdf", "民事诉讼法"),
        ("工伤保险条例.docx", "工伤保险条例"),
        ("消费者权益保护法.docx", "消费者权益保护法"),
        ("行政处罚法.docx", "行政处罚法")
    ]
    
    # 数据库路径
    db_path = "assets/lawpack.db"
    
    # 连接数据库
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    total_chunks = 0
    total_articles = 0
    
    for filename, law_name in law_files:
        file_path = os.path.join(desktop_law_path, filename)
        
        if not os.path.exists(file_path):
            print(f"文件不存在: {file_path}")
            continue
            
        print(f"📖 正在处理: {law_name}")
        
        # 提取文本
        if filename.endswith('.docx'):
            text = extract_text_from_docx(file_path)
        elif filename.endswith('.pdf'):
            text = extract_text_from_pdf(file_path)
        else:
            continue
            
        if not text:
            print(f"  ⚠️ 无法提取文本: {filename}")
            continue
            
        # 分割为条文块
        chunks = split_into_chunks(text, law_name)
        
        if not chunks:
            print(f"  ⚠️ 无法分割条文: {filename}")
            continue
        
        # 插入articles表
        try:
            cursor.execute("""
                INSERT OR REPLACE INTO articles (id, title, content, source, lang)
                VALUES (?, ?, ?, ?, 'zh')
            """, (law_name, law_name, text[:5000], filename))
            total_articles += 1
        except Exception as e:
            print(f"  ❌ 插入文章失败: {e}")
            continue
        
        # 插入chunks表
        chunk_count = 0
        for chunk in chunks:
            try:
                cursor.execute("""
                    INSERT OR REPLACE INTO chunks (id, article_id, content, embedding, lang)
                    VALUES (?, ?, ?, NULL, 'zh')
                """, (chunk['article_id'], law_name, chunk['content']))
                chunk_count += 1
            except Exception as e:
                print(f"  ❌ 插入条文块失败: {e}")
                continue
        
        total_chunks += chunk_count
        print(f"  ✅ 完成: {chunk_count} 个条文块")
    
    # 提交更改
    conn.commit()
    conn.close()
    
    print(f"\n🎉 导入完成!")
    print(f"📚 总文章数: {total_articles}")
    print(f"📄 总条文块: {total_chunks}")
    print(f"💾 数据库: {db_path}")

if __name__ == "__main__":
    import_law_files()