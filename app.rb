require 'sinatra/base'
require 'sinatra/reloader'
require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/web'
require 'elasticsearch'
require 'json'
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
    also_reload './views/*.erb'
    also_reload './tweet.rb'
  end

  get '/' do
    config = YAML.load_file('config.yml')
    db_config = config['database']
    Tweet.setup_db_connection(db_config)
    @tweets = Tweet.fetch_recent_tweets(1000)
    erb :index, layout: :layout
  end

  get '/search' do
    query = params[:query]
    @results = Tweet.search_tweets(query)
    erb :search, layout: :layout
  end

  get '/images/:media_id' do
    media_path = File.join('cache', params[:media_id])
    send_file media_path
  end

  run! if app_file == $0
end
