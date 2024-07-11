class Address < ApplicationRecord
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
