class Address < ApplicationRecord
  include WebRequestHelper
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

    if json_file["status"] == 200 && json_file["result"]
      longitude = json_file["result"]["longitude"]
      latitude = json_file["result"]["latitude"]

      if longitude.nil? || latitude.nil?
        raise "Invalid location data. Longitude or latitude is nil."
      else
        [longitude, latitude]
      end
    else
      raise "Invalid postcode. Please enter a valid UK postcode."
    end
  rescue => e
    Rails.logger.error "Error fetching location data: #{e.message}"
    raise e.message
  end

  def get_stop_types
    web_address = 'https://api.tfl.gov.uk/StopPoint/Meta/StopTypes'
    stop_types = web_request(web_address)
    stop_types.join(',')
  rescue => e
    Rails.logger.error "Error fetching stop types: #{e.message}"
    raise e.message
  end

  def get_nearest_stops
    @stop_types_str ||= get_stop_types
    if @longitude.nil? || @latitude.nil?
      @longitude, @latitude = get_location
    end

    stop_id_dict = {}

    web_address = "https://api.tfl.gov.uk/StopPoint?stopTypes=#{@stop_types_str}&lat=#{@latitude}&lon=#{@longitude}"
    stops_info = web_request(web_address)

    stop_points_sorted = stops_info["stopPoints"].sort_by { |stop| stop["distance"] }
    stop_points_nearest= stop_points_sorted.first(1)

    stop_points_nearest.each do |stop_point|
      stop_point['children'].each do |child|
        stop_id_dict[child['id']] = child['commonName']
      end
    end
    stop_id_dict
  rescue => e
    Rails.logger.error "Error fetching nearest stops: #{e.message}"
    raise e.message

  end
end
