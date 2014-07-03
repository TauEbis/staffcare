class CreateInputProjections < ActiveRecord::Migration
  def change
    create_table :input_projections do |t|
      t.date :start_date
      t.date :end_date
      t.string :location_name
      t.integer :volume
    end
  end
end
