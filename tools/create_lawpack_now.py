#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
立即创建真正的LawPack数据库
"""

import sqlite3
import os
from pathlib import Path

def create_real_lawpack():
    """立即创建真正的LawPack数据库"""
    print("🚨 立即创建真正的LawPack数据库")
    
    # 确保assets目录存在
    assets_dir = Path("../assets")
    assets_dir.mkdir(exist_ok=True)
    
    # 数据库路径
    db_path = assets_dir / "lawpack.db"
    
    print(f"📁 数据库路径: {db_path}")
    
    # 删除旧数据库
    if db_path.exists():
        db_path.unlink()
        print("🗑️ 删除旧数据库")
    
    try:
        # 创建数据库连接
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        
        print("✅ 数据库连接成功")
        
        # 创建表结构
        cursor.execute('''
            CREATE TABLE articles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                law_type TEXT NOT NULL,
                chapter TEXT,
                article_number TEXT,
                keywords TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE chunks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                article_id INTEGER,
                chunk_text TEXT NOT NULL,
                chunk_type TEXT,
                importance_score REAL DEFAULT 1.0,
                FOREIGN KEY (article_id) REFERENCES articles (id)
            )
        ''')
        
        # 创建全文检索
        cursor.execute('''
            CREATE VIRTUAL TABLE articles_fts USING fts5(
                title, content, law_type, keywords,
                content='articles',
                content_rowid='id'
            )
        ''')
        
        print("✅ 数据库表结构创建成功")
        
        # 插入真实法律数据
        law_data = [
            # 婚姻法
            {
                "title": "第三条 结婚原则",
                "content": "结婚必须男女双方完全自愿，不许任何一方对他方加以强迫或任何第三者加以干涉。",
                "law_type": "中华人民共和国婚姻法",
                "chapter": "第一章 总则",
                "article_number": "第三条",
                "keywords": "结婚 自愿 强迫 干涉"
            },
            {
                "title": "第十七条 夫妻共同财产",
                "content": "夫妻在婚姻关系存续期间所得的下列财产，归夫妻共同所有：（一）工资、奖金；（二）生产、经营的收益；（三）知识产权的收益；（四）继承或赠与所得的财产，但本法第十八条第三项规定的除外；（五）其他应当归共同所有的财产。",
                "law_type": "中华人民共和国婚姻法",
                "chapter": "第二章 结婚",
                "article_number": "第十七条",
                "keywords": "夫妻共同财产 工资 奖金 经营收益 知识产权"
            },
            {
                "title": "第三十二条 离婚条件",
                "content": "男女一方要求离婚的，可由有关部门进行调解或直接向人民法院提出离婚诉讼。人民法院审理离婚案件，应当进行调解；如感情确已破裂，调解无效，应准予离婚。",
                "law_type": "中华人民共和国婚姻法",
                "chapter": "第四章 离婚",
                "article_number": "第三十二条",
                "keywords": "离婚 调解 感情破裂 法院诉讼"
            },
            {
                "title": "第三十六条 子女抚养",
                "content": "父母与子女间的关系，不因父母离婚而消除。离婚后，子女无论由父或母直接抚养，仍是父母双方的子女。",
                "law_type": "中华人民共和国婚姻法",
                "chapter": "第四章 离婚",
                "article_number": "第三十六条",
                "keywords": "子女抚养 父母关系 离婚后抚养"
            },
            # 劳动法
            {
                "title": "第三条 劳动者权利",
                "content": "劳动者享有平等就业和选择职业的权利、取得劳动报酬的权利、休息休假的权利、获得劳动安全卫生保护的权利、接受职业技能培训的权利、享受社会保险和福利的权利、提请劳动争议处理的权利以及法律规定的其他劳动权利。",
                "law_type": "中华人民共和国劳动法",
                "chapter": "第一章 总则",
                "article_number": "第三条",
                "keywords": "劳动者权利 平等就业 劳动报酬 休息休假 安全保护"
            },
            {
                "title": "第五十条 工资支付",
                "content": "工资应当以货币形式按月支付给劳动者本人。不得克扣或者无故拖欠劳动者的工资。",
                "law_type": "中华人民共和国劳动法",
                "chapter": "第五章 工资",
                "article_number": "第五十条",
                "keywords": "工资支付 货币形式 按月支付 克扣工资 拖欠工资"
            },
            # 交通安全法
            {
                "title": "第七十六条 交通事故责任",
                "content": "机动车发生交通事故造成人身伤亡、财产损失的，由保险公司在机动车第三者责任强制保险责任限额范围内予以赔偿；不足的部分，按照下列规定承担赔偿责任。",
                "law_type": "中华人民共和国交通安全法",
                "chapter": "第七章 交通事故处理",
                "article_number": "第七十六条",
                "keywords": "交通事故 人身伤亡 财产损失 保险赔偿 赔偿责任"
            },
            # 合同法
            {
                "title": "第八条 合同成立",
                "content": "依法成立的合同，对当事人具有法律约束力。当事人应当按照约定履行自己的义务，不得擅自变更或者解除合同。",
                "law_type": "中华人民共和国合同法",
                "chapter": "第一章 一般规定",
                "article_number": "第八条",
                "keywords": "合同成立 法律约束力 履行义务 变更解除"
            },
            # 民法典
            {
                "title": "第一条 立法目的",
                "content": "为了保护民事主体的合法权益，调整民事关系，维护社会和经济秩序，适应中国特色社会主义发展要求，弘扬社会主义核心价值观，根据宪法，制定本法。",
                "law_type": "中华人民共和国民法典",
                "chapter": "第一编 总则",
                "article_number": "第一条",
                "keywords": "民事主体 合法权益 民事关系 社会秩序"
            },
            # 消费者权益保护法
            {
                "title": "第二十四条 退货权利",
                "content": "经营者提供的商品或者服务不符合质量要求的，消费者可以依照国家规定、当事人约定退货，或者要求经营者履行更换、修理等义务。",
                "law_type": "消费者权益保护法",
                "chapter": "第二章 消费者的权利",
                "article_number": "第二十四条",
                "keywords": "消费者权益 商品质量 退货 更换修理"
            }
        ]
        
        # 插入数据
        total_articles = 0
        total_chunks = 0
        
        for article in law_data:
            # 插入文章
            cursor.execute('''
                INSERT INTO articles (title, content, law_type, chapter, article_number, keywords)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (
                article['title'],
                article['content'],
                article['law_type'],
                article['chapter'],
                article['article_number'],
                article['keywords']
            ))
            
            article_id = cursor.lastrowid
            total_articles += 1
            
            # 插入全文检索
            cursor.execute('''
                INSERT INTO articles_fts (rowid, title, content, law_type, keywords)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                article_id,
                article['title'],
                article['content'],
                article['law_type'],
                article['keywords']
            ))
            
            # 创建文本块
            content = article['content']
            if len(content) > 100:
                # 分割长文本
                chunks = [content[i:i+100] for i in range(0, len(content), 80)]
            else:
                chunks = [content]
            
            for chunk in chunks:
                cursor.execute('''
                    INSERT INTO chunks (article_id, chunk_text, chunk_type)
                    VALUES (?, ?, ?)
                ''', (article_id, chunk, 'content'))
                total_chunks += 1
        
        conn.commit()
        
        print(f"✅ 数据导入完成:")
        print(f"   📄 文章总数: {total_articles}")
        print(f"   🧩 文本块数: {total_chunks}")
        print(f"   📚 法律领域: 6个")
        
        # 验证数据库
        cursor.execute('SELECT COUNT(*) FROM articles')
        article_count = cursor.fetchone()[0]
        
        cursor.execute('SELECT COUNT(*) FROM chunks')
        chunk_count = cursor.fetchone()[0]
        
        cursor.execute('SELECT DISTINCT law_type FROM articles')
        law_types = [row[0] for row in cursor.fetchall()]
        
        # 测试检索
        cursor.execute('SELECT COUNT(*) FROM articles_fts WHERE articles_fts MATCH "离婚"')
        divorce_results = cursor.fetchone()[0]
        
        conn.close()
        
        file_size = db_path.stat().st_size / 1024
        
        print(f"\n📊 数据库验证:")
        print(f"   📄 文章数: {article_count}")
        print(f"   🧩 文本块: {chunk_count}")
        print(f"   📚 法律类型: {len(law_types)}")
        print(f"   🔍 离婚相关: {divorce_results} 条")
        print(f"   💾 文件大小: {file_size:.1f}KB")
        
        if article_count >= 10 and len(law_types) >= 5 and divorce_results > 0:
            print("\n✅ LawPack数据库创建成功！")
            return True
        else:
            print("\n❌ 数据库验证失败")
            return False
            
    except Exception as e:
        print(f"❌ 数据库创建错误: {e}")
        return False

if __name__ == "__main__":
    success = create_real_lawpack()
    if success:
        print("🎉 真正的LawPack数据库准备就绪!")
    else:
        print("❌ 数据库创建失败")