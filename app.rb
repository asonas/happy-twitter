require 'sinatra/base'
require 'sinatra/reloader'
require 'sidekiq'
require 'elasticsearch'
require 'pg'
require 'yaml'
require_relative 'models/tweet'
require_relative 'workers/media_download_worker'

# 設定ファイルの読み込み
config = YAML.load_file('config/config.yml')
db_config = config['database']
es_config = config['elasticsearch']

Tweet.setup_db_connection(db_config)
Tweet.setup_es_connection(es_config)

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload './models/tweet.rb'
  end

  before do
    @config = YAML.load_file('config/config.yml')
    @db_config = @config['database']
    Tweet.setup_db_connection(@db_config)
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
            'Access-Control-Allow-Headers' => 'X-Requested-With, Content-Type, Accept, Authorization'
  end

  get '/api/tweets' do
    content_type :json
    offset = params[:offset].to_i || 0
    tweets = Tweet.fetch_recent_tweets_with_media(100, offset)
    tweets.to_json
  end

  get '/images/:media_id' do
    media_path = File.join('cache', params[:media_id])
    send_file media_path
  end

  run! if app_file == $0
end
