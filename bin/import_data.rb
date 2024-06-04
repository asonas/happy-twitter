require 'pg'
require 'yaml'
require 'elasticsearch'

config = YAML.load_file('config/config.yml')
db_config = config['database']
es_config = config['elasticsearch']

conn = PG.connect(
  dbname: db_config['database'],
  user: db_config['user'],
  password: db_config['password'],
  host: db_config['host']
)

client = Elasticsearch::Client.new(url: es_config['url'], log: true)

res = conn.exec('SELECT * FROM tweets')

res.each do |row|
  client.index(
    index: 'twitter_likes',
    id: row['original_tweet_id'],
    body: {
      user_id: row['user_id'],
      original_tweet_id: row['original_tweet_id'],
      original_tweet_id_str: row['original_tweet_id_str'],
      url: row['url'],
      date: row['date'],
      content: row['content'],
      reply_count: row['reply_count'],
      retweet_count: row['retweet_count'],
      like_count: row['like_count'],
      quote_count: row['quote_count'],
      conversation_id: row['conversation_id'],
      conversation_id_str: row['conversation_id_str'],
      source: row['source']
    }
  )
end

conn.close
