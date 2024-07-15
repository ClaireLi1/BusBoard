class BusPredictionController < ApplicationController
  def index

  end

  def bus_prediction_from_postcode
    postcode = params[:postcode]

    address = Address.new(postcode)
    stop_id_list = address.get_nearest_stops

    @results = stop_id_list.map do |stop_id|
      stop_instance = BusStop.new(stop_id)
      stop_instance.bus_prediction(1)
    end

    render :index
  end
end
