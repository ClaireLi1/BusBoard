require 'net/http'
require 'uri'
require 'json'

module WebRequest
  def web_request(web_address)

    uri = URI(web_address)

    response = Net::HTTP.get_response(uri)

    JSON.parse(response.body)

  end
end

class BusStop
  include WebRequest

  attr_accessor :stop_id, :buses_info

  def initialize(stop_id)
    @stop_id = stop_id
    @buses_info_sorted = nil
  end

  def fetch_buses_info
    web_address = "https://api.tfl.gov.uk/StopPoint/#{@stop_id}/Arrivals"
    buses_info = web_request(web_address)
    buses_info.sort_by { |bus| bus["timeToStation"] }
  end

  def bus_prediction(number_of_buses)
    @buses_info_sorted = fetch_buses_info

    next_buses = @buses_info_sorted.first(number_of_buses)

    next_buses.each do |bus|
      puts "StopID: #{@stop_id}, Route: #{bus['lineId']}, Destination: #{bus['destinationName']}, Arrives in: #{bus['timeToStation']/60} minutes"
    end

  end

end

class Address
  include WebRequest
  def initialize(postcode)
    @postcode = postcode
    @longitude = nil
    @latitude = nil
    @stop_types_str = nil
    @stop_id_list = []
  end
  def get_location

    web_address = "https://api.postcodes.io/postcodes/#{@postcode}"

    json_file = web_request(web_address)

    longitude = json_file["result"]["longitude"]
    latitude = json_file["result"]["latitude"]

    [longitude, latitude]

  end

  def get_stop_types
    web_address = 'https://api.tfl.gov.uk/StopPoint/Meta/StopTypes'
    stop_types = web_request(web_address)
    stop_types.join(',')
  end

  def get_nearest_stops
    @stop_types_str ||= get_stop_types
    if @longitude.nil? || @latitude.nil?
      @longitude, @latitude = get_location
    end

    stop_id_list = []

    web_address = "https://api.tfl.gov.uk/StopPoint?stopTypes=#{@stop_types_str}&lat=#{@latitude}&lon=#{@longitude}"
    stops_info = web_request(web_address)

    stop_points_sorted = stops_info["stopPoints"].sort_by { |stop| stop["distance"] }
    stop_points_nearest= stop_points_sorted.first(1)

    stop_points_nearest.each do |stop_point|
      stop_point['children'].each do |child|
        stop_id_list.append(child['id'])
      end
    end
    stop_id_list

  end

end

puts 'Enter your postcode'
postcode = gets.chomp
address = Address.new(postcode)
stop_id_list = address.get_nearest_stops

for stop_id in stop_id_list do
  stop_instance = BusStop.new(stop_id)
  stop_instance.bus_prediction(1)
end