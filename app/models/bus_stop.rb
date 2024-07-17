class BusStop < ApplicationRecord
  include WebRequestHelper

  attr_accessor :stop_id, :buses_info

  def initialize(stop_id)
    @stop_id = stop_id
    @buses_info_sorted = nil
  end

  def fetch_buses_info
    web_address = "https://api.tfl.gov.uk/StopPoint/#{@stop_id}/Arrivals"
    buses_info = web_request(web_address)
    buses_info.sort_by { |bus| bus["timeToStation"] }
  rescue => e
    Rails.logger.error "Error fetching buses information: #{e.message}"
    raise e.message
  end

  def bus_prediction(number_of_buses)
    @buses_info_sorted = fetch_buses_info
    if @buses_info_sorted.empty?
      return 'No buses arriving at this stop.'
    end

    next_buses = @buses_info_sorted.first(number_of_buses)

    next_buses.each do |bus|
      result = "Route: #{bus['lineId']}, Destination: #{bus['destinationName']}, Arrives in: #{bus['timeToStation']/60} minutes"
      return result
    end

  rescue => e
    Rails.logger.error "Error making bus predictions: #{e.message}"
    raise e.message
  end
end
