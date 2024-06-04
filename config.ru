require 'sidekiq/web'
require_relative 'app'

use Rack::Session::Cookie, secret: File.read(".session.key"), same_site: true, max_age: 86400

run Rack::URLMap.new(
  '/' => App,
  '/sidekiq' => Sidekiq::Web
)
