require 'net/http'
require 'uri'
require 'json'

def web_request(id)
  require 'net/http'

  uri = URI("https://api.tfl.gov.uk/StopPoint/#{id}/Arrivals")


  request = Net::HTTP::Get.new(uri.request_uri)

  # Request headers
  request['Cache-Control'] = 'no-cache'


  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(request)
  end

  puts response.code
  puts response.body

end

web_request('490008660N')