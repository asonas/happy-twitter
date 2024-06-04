CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  original_user_id BIGINT UNIQUE,
  original_user_id_str VARCHAR(255) UNIQUE,
  username VARCHAR(255),
  displayname VARCHAR(255),
  raw_description TEXT,
  created TIMESTAMP,
  followers_count INT,
  friends_count INT,
  statuses_count INT,
  favourites_count INT,
  listed_count INT,
  media_count INT,
  location VARCHAR(255),
  profile_image_url VARCHAR(255),
  profile_banner_url VARCHAR(255),
  verified BOOLEAN
);

CREATE TABLE IF NOT EXISTS tweets (
  id SERIAL PRIMARY KEY,
  original_tweet_id BIGINT UNIQUE,
  original_tweet_id_str VARCHAR(255) UNIQUE,
  user_id INTEGER REFERENCES users(id),
  url VARCHAR(255),
  date TIMESTAMP,
  content TEXT,
  reply_count INT,
  retweet_count INT,
  like_count INT,
  quote_count INT,
  conversation_id BIGINT,
  conversation_id_str VARCHAR(255),
  source VARCHAR(255),
  original_json JSONB
);

CREATE TABLE IF NOT EXISTS media (
  id SERIAL PRIMARY KEY,
  tweet_id BIGINT REFERENCES tweets(id),
  url VARCHAR(255),
  type VARCHAR(50)
);
