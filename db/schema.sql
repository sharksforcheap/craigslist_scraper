-- This DROP statement drops a table if it exists and does nothing otherwise
--
-- SQLite will raise an error if we try to CREATE a table that 
-- already exists, or DROP a table that doesn't

DROP TABLE IF EXISTS listings;

CREATE TABLE listings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title VARCHAR NOT NULL,
  url VARCHAR NOT NULL,
  price VARCHAR,
  body TEXT NOT NULL
);
