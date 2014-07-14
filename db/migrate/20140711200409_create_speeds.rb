class CreateSpeeds < ActiveRecord::Migration
  def change
    create_table :speeds do |t|
    	t.integer :doctors, null: false
      t.decimal :normal, precision: 5, scale: 2, null: false
      t.decimal :max, precision: 5, scale: 2, null: false
      t.references :location, index: true

      t.timestamps
    end

    add_index :speeds, [:doctors, :location_id], unique: true
  end
end
