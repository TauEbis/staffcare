class AddDetailsToLocations < ActiveRecord::Migration
  def change
    Location::DAYS.each do |day|
      add_column :locations, "#{day}_open", :integer
      add_column :locations, "#{day}_close", :integer
    end
    add_column :locations, :rooms, :integer
    add_column :locations, :max_mds, :integer
    add_column :locations, :report_server_id, :string
  end
end
