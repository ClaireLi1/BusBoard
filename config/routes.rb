Rails.application.routes.draw do

  root "bus_prediction#index"

  post "bus_prediction_from_postcode", to: "bus_prediction#bus_prediction_from_postcode"
end
