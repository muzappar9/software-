# LawPack CN ETL

This folder contains a minimal ETL to convert Chinese law txt/md files into `assets/lawpack.db`.

Usage:

1. Put source txt/md files into `tools/lawpack_cn/demo_src/` (filenames as law names).
2. Run the build script in PowerShell:

```powershell
cd tools/lawpack_cn
python etl_from_txt.py --src_dir demo_src --out ../../assets/lawpack.db --lang zh
```

Or use the provided `build_demo.ps1` which wraps the command.

The generated DB contains:
- `articles` table (metadata per article)
- `chunks` FTS5 virtual table (each chunk is a law article or clause)
- `vectors` placeholder table (zero vectors, dim=384)

FTS example:

```sql
SELECT article_no, snippet(chunks,'[',']','…',-1,10) FROM chunks WHERE chunks MATCH '离婚 AND 抚养' LIMIT 5;
```

Notes:
- This is a starter pipeline; after you have vector embeddings, replace `vectors.vec` with real embeddings.
- Only use authoritative public domain or licensed texts.

