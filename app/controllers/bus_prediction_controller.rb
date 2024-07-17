class BusPredictionController < ApplicationController
  before_action :validate_postcode, only: [:bus_prediction_from_postcode]
  def index
    @results
  end

  def bus_prediction_from_postcode
    postcode = params[:postcode]

    begin
      address = Address.new(postcode)
      stop_id_dict = address.get_nearest_stops

      if stop_id_dict.empty?
        flash.now[:alert] = "There are no available bus stops near this postcode."
      else
        @results = stop_id_dict.keys.map do |stop_id|
          stop_instance = BusStop.new(stop_id)
          "StopName: "+ stop_id_dict[stop_id] + " | " + stop_instance.bus_prediction(1)
        end

        if @results.empty?
          flash.now[:alert] = "There are no available buses near this postcode."
        end
      end

    rescue => e
      flash.now[:alert] = e.message
    end
    render :index
  end

  private

  def validate_postcode
    postcode = params[:postcode]
    unless postcode.match?(/\A[A-Z]{1,2}\d[A-Z\d]?\d[A-Z]{2}\z/i)
      flash.now[:alert] = "Invalid postcode format. Please enter a valid UK postcode (e.g., NW51TL)."
      render :index
    end
  end
end
