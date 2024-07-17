require 'net/http'
require 'uri'
require 'json'
module WebRequestHelper
  def web_request(web_address)

    uri = URI(web_address)

    response = Net::HTTP.get_response(uri)

    JSON.parse(response.body)

  end
end