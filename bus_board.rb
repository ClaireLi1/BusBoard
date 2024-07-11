require 'net/http'
require 'uri'
require 'json'

class BusStop

  def initialize(id)
    @id = id
    @buses_info = {}
  end

  def web_request()
    uri = URI("https://api.tfl.gov.uk/StopPoint/#{@id}/Arrivals")

    response = Net::HTTP.get_response(uri)

    json_file = JSON.parse(response.body)

    @buses_info = json_file

  end

  def bus_prediction()
    sorted_buses = @buses_info.sort_by { |bus| bus["timeToStation"] }
    next_five_buses = sorted_buses.first(5)

    next_five_buses.each do |bus|
      puts "Route: #{bus['lineId']}, Destination: #{bus['destinationName']}, Arrives in: #{bus['timeToStation']/60} minutes"
    end

  end

end


puts 'Enter a valid stop ID'
stop_id = gets.chomp
Stop = BusStop.new(stop_id)
Stop.web_request
Stop.bus_prediction




