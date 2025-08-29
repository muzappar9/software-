#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os, re, sys, json, sqlite3, struct, argparse, hashlib
from datetime import datetime
import yaml

def float32_zeros(dim):
    return struct.pack('<'+'f'*dim, *([0.0]*dim))

def load_rules(path):
    with open(path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)

def norm_text(s, rules):
    if rules.get('normalize', {}).get('strip_space', True):
        s = s.strip()
    if rules.get('normalize', {}).get('collapse_whitespace', True):
        s = re.sub(r'\s+', ' ', s)
    return s

def guess_lawcode(fname):
    base = os.path.splitext(os.path.basename(fname))[0]
    return hashlib.md5(base.encode('utf-8')).hexdigest()[:8].upper()

def split_articles(text, pattern):
    parts = re.split(pattern, text)
    res, cur = [], ""
    for p in parts:
        if not p: continue
        if re.match(pattern, p):
            if cur.strip(): res.append(cur.strip())
            cur = p
        else:
            cur += p
    if cur.strip(): res.append(cur.strip())
    return res

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--src_dir', required=True)
    ap.add_argument('--out', default='assets/lawpack.db')
    ap.add_argument('--rules', default='tools/lawpack_cn/chunk_rules.yaml')
    ap.add_argument('--lang', default='zh')
    ap.add_argument('--dim', type=int, default=384)
    args = ap.parse_args()

    rules = load_rules(args.rules)
    patt = rules['split_patterns'][0]
    patt = re.compile(patt)

    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    if os.path.exists(args.out): os.remove(args.out)
    conn = sqlite3.connect(args.out)
    cur = conn.cursor()
    with open('tools/lawpack_cn/schema.sql', 'r', encoding='utf-8') as f:
        cur.executescript(f.read())

    created_at = datetime.utcnow().isoformat()+'Z'
    cur.execute("INSERT OR REPLACE INTO meta(key,value) VALUES('created_at',?)", (created_at,))
    cur.execute("INSERT OR REPLACE INTO meta(key,value) VALUES('builder_version',?)", ('v0-generic',))
    cur.execute("INSERT OR REPLACE INTO meta(key,value) VALUES('lang',?)", (args.lang,))

    total_articles, total_chunks = 0, 0
    for fname in sorted(os.listdir(args.src_dir)):
        if not fname.lower().endswith(('.txt','.md')): continue
        path = os.path.join(args.src_dir, fname)
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            raw = f.read()
        raw = norm_text(raw, rules)
        lawcode = guess_lawcode(fname)
        lawname = os.path.splitext(fname)[0]

        articles = split_articles(raw, patt)
        for art in articles:
            m = re.match(r'(第[一二三四五六七八九十百千万零〇0-9]+条)[：:，,]?\s*', art)
            article_no = m.group(1) if m else ''
            body = art[m.end():].strip() if m else art
            if not body: continue

            article_id = f"{lawcode}:{hashlib.md5(article_no.encode('utf-8')).hexdigest()[:8]}"
            cur.execute("""INSERT OR REPLACE INTO articles
                (id, lawcode, law_name, article_no, article_title, lang, effective_from, effective_to, version_id, source_url)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                (article_id, lawcode, lawname, article_no, '', args.lang, None, None, 'local-dev', None)
            )

            chunk_id = f"{article_id}"
            topic = ''
            cur.execute("""INSERT INTO chunks (id, article_id, topic, text, lang, lawcode, article_no)
                           VALUES (?, ?, ?, ?, ?, ?, ?)""",
                        (chunk_id, article_id, topic, body, args.lang, lawcode, article_no))
            cur.execute("""INSERT OR REPLACE INTO vectors (id, dim, vec) VALUES (?, ?, ?)""",
                        (chunk_id, args.dim, float32_zeros(args.dim)))
            total_articles += 1
            total_chunks += 1

    conn.commit()
    try:
        cur.execute("INSERT INTO chunks(chunks) VALUES('optimize')"); conn.commit()
    except:
        pass

    print(f"[OK] built {args.out}")
    print(f" articles: {total_articles}, chunks: {total_chunks}")
    print(" try: SELECT article_no, snippet(chunks,'[',']','…',-1,10) FROM chunks WHERE chunks MATCH '离婚 AND 抚养' LIMIT 5;")
    conn.close()

if __name__ == "__main__":
    main()

