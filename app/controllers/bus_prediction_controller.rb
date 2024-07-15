class BusPredictionController < ApplicationController
  def index

  end

  def bus_prediction_from_postcode
    postcode = params[:postcode]
    # Rails.logger.debug "Postcode: #{postcode}"

    address = Address.new(postcode)
    stop_id_list = address.get_nearest_stops
    # Rails.logger.debug "Stop ID List: #{stop_id_list.inspect}"

    @results = stop_id_list.map do |stop_id|
      stop_instance = BusStop.new(stop_id)
      stop_instance.bus_prediction(1)
    end

    # logger.debug "Postcode: #{postcode}"
    # logger.debug "Stop ID List: #{stop_id_list.inspect}"
    # logger.debug "Predictions: #{@results.inspect}"
    #
    # Rails.logger.debug "Predictions: #{@results.inspect}"

    render :index
  end
end
