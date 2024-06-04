require 'elasticsearch'
require 'yaml'

config = YAML.load_file('config/config.yml')
es_config = config['elasticsearch']

client = Elasticsearch::Client.new(url: es_config['url'], log: true)

client.indices.create(
  index: 'twitter_likes',
  body: {
    settings: {
      analysis: {
        tokenizer: {
          kuromoji_tokenizer: {
            type: 'kuromoji_tokenizer'
          }
        },
        analyzer: {
          kuromoji_analyzer: {
            type: 'custom',
            tokenizer: 'kuromoji_tokenizer',
            filter: ['kuromoji_baseform', 'kuromoji_part_of_speech', 'cjk_width', 'ja_stop', 'kuromoji_number', 'kuromoji_stemmer', 'lowercase']
          }
        }
      }
    },
    mappings: {
      properties: {
        user_id: { type: 'integer' },
        original_tweet_id: { type: 'long' },
        original_tweet_id_str: { type: 'keyword' },
        url: { type: 'keyword' },
        date: {
          type: 'date',
          format: 'yyyy-MM-dd HH:mm:ss||yyyy-MM-dd HH:mm:ssZ||strict_date_optional_time||epoch_millis'
        },
        content: {
          type: 'text',
          analyzer: 'kuromoji_analyzer'
        },
        reply_count: { type: 'integer' },
        retweet_count: { type: 'integer' },
        like_count: { type: 'integer' },
        quote_count: { type: 'integer' },
        conversation_id: { type: 'long' },
        conversation_id_str: { type: 'keyword' },
        source: { type: 'keyword' }
      }
    }
  }
)

puts "Index 'twitter_likes' with kuromoji analyzer has been created."
