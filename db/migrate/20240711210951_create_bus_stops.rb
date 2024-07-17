class CreateBusStops < ActiveRecord::Migration[7.1]
  def change
    create_table :bus_stops do |t|

      t.timestamps
    end
  end
end
