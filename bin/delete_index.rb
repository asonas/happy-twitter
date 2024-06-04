require 'elasticsearch'
require 'yaml'

es_config = YAML.load_file('config/config.yml')['elasticsearch']

client = Elasticsearch::Client.new(url: es_config['url'], log: true)

index_name = 'twitter_likes'

begin
  client.indices.delete(index: index_name)
  puts "Index '#{index_name}' has been deleted."
end
