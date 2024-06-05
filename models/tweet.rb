require 'pg'
require 'elasticsearch'
require 'json'
require 'net/http'
require 'uri'
require 'fileutils'
require 'securerandom'
require 'sidekiq'
require_relative '../workers/media_download_worker'

class Tweet
  CACHE_DIR = 'cache'

  def self.setup_db_connection(db_config)
    @db_conn = PG.connect(
      dbname: db_config['database'],
      user: db_config['user'],
      password: db_config['password'],
      host: db_config['host']
    )
  end

  def self.setup_es_connection(es_config)
    @es_client = Elasticsearch::Client.new(url: es_config['url'], log: true)
  end

  def self.fetch_recent_tweets(count)
    response = @es_client.search(
      index: 'twitter_likes',
      body: {
        sort: [{ date: { order: 'desc' } }],
        size: count
      }
    )
    response['hits']['hits'].map { |hit| enrich_tweet(hit['_source']) }
  end

  def self.fetch_recent_tweets_with_media(limit, offset)
    @db_conn.exec_params(
      "SELECT * FROM tweets WHERE media_url IS NOT NULL ORDER BY created_at DESC LIMIT $1 OFFSET $2",
      [limit, offset]
    )
  end

  def self.search_tweets(query)
    response = @es_client.search(
      index: 'twitter_likes',
      body: {
        query: {
          multi_match: {
            query: query,
            fields: ['content']
          }
        }
      }
    )
    response['hits']['hits'].map { |hit| enrich_tweet(hit['_source']) }
  end

  def self.enrich_tweet(tweet)
    media_res = @db_conn.exec_params('SELECT m.* FROM media m INNER JOIN tweets t ON t.id = m.tweet_id WHERE t.original_tweet_id = $1', [tweet['original_tweet_id']])
    tweet['media'] = media_res.map { |row| cache_media(row) }.compact
    tweet
  end

  def self.cache_media(media)
    media_path = File.join(CACHE_DIR, media['id'])

    if File.exist?(media_path)
      media['cached_url']= "http://10.0.2.200:4567/images/#{media['id']}"
    else
      MediaDownloadWorker.perform_async(media['url'], media_path)
    end
    media
  end
end
