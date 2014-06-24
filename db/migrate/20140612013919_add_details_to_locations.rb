class AddDetailsToLocations < ActiveRecord::Migration
  def change
    Location::DAYS.each do |day|
      add_column :locations, "#{day}_open", :integer, null: false, default: 480
      add_column :locations, "#{day}_close", :integer, null: false, default: 1260
    end
    add_column :locations, :rooms, :integer, null: false, default: 1
    add_column :locations, :max_mds, :integer, null: false, default: 1
    add_column :locations, :min_openers, :integer, null: false, default: 1
    add_column :locations, :min_closers, :integer, null: false, default: 1
    add_column :locations, :report_server_id, :string
  end
end
