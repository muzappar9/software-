# -*- coding: utf-8 -*-
import os, re, argparse, sys, pathlib

def norm_text(s):
    s = s.replace("\u3000"," ").replace("\r\n","\n").replace("\r","\n")
    s = re.sub(r'第\s*([一二三四五六七八九十百千万零〇0-9]+)\s*条', r'第\1条', s)
    s = re.sub(r'\s*(第[一二三四五六七八九十百千万零〇0-9]+条)[：:，,]?\s*', r'\n\1 ', s)
    s = re.sub(r'[ \t]+',' ', s)
    s = re.sub(r'\n{3,}','\n\n', s)
    return s.strip()

def read_docx(p):
    from docx import Document
    return "\n".join([x.text for x in Document(p).paragraphs])

def read_pdf(p):
    from pdfminer.high_level import extract_text
    t = extract_text(p) or ""
    if len(t.strip())<50:
        print(f"[WARN] {p} 可能需要OCR")
    return t

def slurp(p):
    return open(p,'r',encoding='utf-8',errors='ignore').read()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--src_mixed', default='tools/lawpack_cn/demo_src_mixed')
    ap.add_argument('--out_dir',   default='tools/lawpack_cn/demo_src')
    a = ap.parse_args()
    in_dir, out_dir = pathlib.Path(a.src_mixed), pathlib.Path(a.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    exts = {'.docx','.pdf','.txt','.md'}; c=0
    for p in sorted(in_dir.glob("*")):
        if not p.is_file() or p.suffix.lower() not in exts: continue
        try:
            if p.suffix.lower()=='.docx': raw = read_docx(str(p))
            elif p.suffix.lower()=='.pdf': raw = read_pdf(str(p))
            else: raw = slurp(str(p))
            out = norm_text(raw)
            (out_dir/(p.stem+'.txt')).write_text(out, encoding='utf-8')
            print(f"[OK] {p.name} -> {p.stem+'.txt'} ({len(out)} chars)"); c+=1
        except Exception as e:
            print(f"[ERR] {p.name}: {e}", file=sys.stderr)
    print(f"完成：{c} 个文件已输出到 {out_dir}")

if __name__=='__main__': main()

