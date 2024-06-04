require 'pg'
require 'json'
require 'yaml'
require 'time'

config = YAML.load_file('config/config.yml')
db_config = config['database']

conn = PG.connect(
  dbname: db_config['database'],
  user: db_config['user'],
  password: db_config['password'],
  host: db_config['host']
)

File.open(ARGV[0], 'r').each_line do |line|
  tweet = JSON.parse(line)

  user = tweet['user']
  begin
    conn.exec_params(
      'INSERT INTO users (original_user_id, original_user_id_str, username, displayname, raw_description, created, followers_count, friends_count, statuses_count, favourites_count, listed_count, media_count, location, profile_image_url, profile_banner_url, verified) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16) ON CONFLICT (original_user_id) DO NOTHING',
      [user['id'], user['id_str'], user['username'], user['displayname'], user['rawDescription'], user['created'], user['followersCount'], user['friendsCount'], user['statusesCount'], user['favouritesCount'], user['listedCount'], user['mediaCount'], user['location'], user['profileImageUrl'], user['profileBannerUrl'], user['verified']]
    )
  rescue PG::UniqueViolation
    puts "User #{user['id']} already exists. Skipping..."
  end

  user_id_result = conn.exec_params('SELECT id FROM users WHERE original_user_id = $1', [user['id']])
  user_id = user_id_result[0]['id'].to_i

  begin
    conn.exec_params(
      'INSERT INTO tweets (original_tweet_id, original_tweet_id_str, user_id, url, date, content, reply_count, retweet_count, like_count, quote_count, conversation_id, conversation_id_str, source, original_json) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) ON CONFLICT (original_tweet_id) DO NOTHING',
      [tweet['id'], tweet['id_str'], user_id, tweet['url'], tweet['date'], tweet['rawContent'], tweet['replyCount'], tweet['retweetCount'], tweet['likeCount'], tweet['quoteCount'], tweet['conversationId'], tweet['conversationIdStr'], tweet['sourceLabel'], tweet.to_json]
    )
  rescue PG::UniqueViolation
    puts "Tweet #{tweet['id']} already exists. Skipping..."
  end

  tweet_id_result = conn.exec_params('SELECT id FROM tweets WHERE original_tweet_id = $1', [tweet['id']])
  tweet_id = tweet_id_result[0]['id'].to_i

  if tweet['media'] && tweet['media']['photos']
    tweet['media']['photos'].each do |photo|
      begin
        conn.exec_params(
          'INSERT INTO media (tweet_id, url, type) VALUES ($1, $2, $3)',
          [tweet_id, photo['url'], 'photo']
        )
      rescue PG::ForeignKeyViolation
        puts "Media #{photo['url']} cannot be inserted because the tweet does not exist. Skipping..."
      rescue => e
        puts "Error inserting media #{photo['url']}: #{e.message}"
      end
    end
  end

  if tweet['media'] && tweet['media']['videos']
    tweet['media']['videos'].each do |video|
      video_url = video['variants'][0]['url']
      begin
        conn.exec_params(
          'INSERT INTO media (tweet_id, url, type) VALUES ($1, $2, $3)',
          [tweet_id, video_url, 'video']
        )
      rescue PG::ForeignKeyViolation
        puts "Media #{video_url} cannot be inserted because the tweet does not exist. Skipping..."
      rescue => e
        puts "Error inserting media #{video_url}: #{e.message}"
      end
    end
  end

  if tweet['media'] && tweet['media']['animated']
    tweet['media']['animated'].each do |animated|
      begin
        conn.exec_params(
          'INSERT INTO media (tweet_id, url, type) VALUES ($1, $2, $3)',
          [tweet_id, animated['videoUrl'], 'animated']
        )
      rescue PG::ForeignKeyViolation
        puts "Media #{animated['videoUrl']} cannot be inserted because the tweet does not exist. Skipping..."
      rescue => e
        puts "Error inserting media #{animated['videoUrl']}: #{e.message}"
      end
    end
  end
end

require_relative 'workers/media_download_worker'

media = conn.exec_params('SELECT * FROM media;')
media.each do |m|
  media_path = File.join('cache', m['id'])

  if File.exist?(media_path)
  else
    MediaDownloadWorker.perform_async(m['url'], media_path)
  end
end

conn.close
