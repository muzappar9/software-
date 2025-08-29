PRAGMA journal_mode=WAL;
PRAGMA synchronous=OFF;

CREATE TABLE IF NOT EXISTS meta(
  key TEXT PRIMARY KEY,
  value TEXT
);

CREATE TABLE IF NOT EXISTS articles(
  id TEXT PRIMARY KEY,
  lawcode TEXT,
  law_name TEXT,
  article_no TEXT,
  article_title TEXT,
  lang TEXT,
  effective_from TEXT,
  effective_to TEXT,
  version_id TEXT,
  source_url TEXT
);

CREATE VIRTUAL TABLE IF NOT EXISTS chunks USING fts5(
  id UNINDEXED,
  article_id UNINDEXED,
  topic,
  text,
  lang,
  lawcode,
  article_no,
  tokenize='unicode61'
);

CREATE TABLE IF NOT EXISTS vectors(
  id TEXT PRIMARY KEY,
  dim INTEGER,
  vec BLOB
);

CREATE INDEX IF NOT EXISTS idx_articles_code_no ON articles(lawcode, article_no);

