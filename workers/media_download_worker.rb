require 'sidekiq'
require 'net/http'
require 'uri'
require 'fileutils'

class MediaDownloadWorker
  include Sidekiq::Worker

  def perform(url, media_path)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
      FileUtils.mkdir_p(File.dirname(media_path))
      File.open(media_path, 'wb') do |file|
        file.write(response.body)
      end
    end
  end
end
