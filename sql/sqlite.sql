CREATE TABLE commentators (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  twitter_id TEXT NOT NULL,
  icon_url TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
CREATE UNIQUE INDEX commentators_i1 ON commentators(twitter_id);
