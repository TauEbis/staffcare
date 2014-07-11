class CreateInputProjections < ActiveRecord::Migration
  def change
    create_table :input_projections do |t|
      t.date :start_date
      t.date :end_date
      t.json :volume_by_location, null: false, default: {}
    end
  end
end
