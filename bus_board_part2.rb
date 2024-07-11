require 'net/http'
require 'uri'
require 'json'

module WebRequest
  def web_request(uri)

    response = Net::HTTP.get_response(uri)

    JSON.parse(response.body)

  end
end

class BusStop
  include WebRequest

  attr_accessor :stop_id, :buses_info

  def initialize(stop_id)
    @stop_id = stop_id
    @buses_info = nil
  end

  def fetch_buses_info
    uri = URI("https://api.tfl.gov.uk/StopPoint/#{@stop_id}/Arrivals")
    @buses_info = web_request(uri)
  end

  def bus_prediction(number_of_buses)
    sorted_buses = @buses_info.sort_by { |bus| bus["timeToStation"] }
    next_buses = sorted_buses.first(number_of_buses)

    next_buses.each do |bus|
      puts "Route: #{bus['lineId']}, Destination: #{bus['destinationName']}, Arrives in: #{bus['timeToStation']/60} minutes"
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

    uri = URI("https://api.postcodes.io/postcodes/#{@postcode}")

    json_file = web_request(uri)

    @longitude = json_file["result"]["longitude"]
    @latitude = json_file["result"]["latitude"]

  end

  def get_stop_types
    uri = URI('https://api.tfl.gov.uk/StopPoint/Meta/StopTypes')
    stop_types = web_request(uri)
    @stop_types_str = stop_types.join(',')
  end

  def get_nearest_stops

    stop_id_list = []

    uri = URI("https://api.tfl.gov.uk/StopPoint?stopTypes=#{@stop_types_str}&lat=#{@latitude}&lon=#{@longitude}")
    stops_info = web_request(uri)

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
address.get_location
address.get_stop_types
stop_id_list = address.get_nearest_stops

for stop_id in stop_id_list do
  stop_instance = BusStop.new(stop_id)
  stop_instance.fetch_buses_info
  stop_instance.bus_prediction(1)
end