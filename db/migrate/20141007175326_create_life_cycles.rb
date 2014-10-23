class CreateLifeCycles < ActiveRecord::Migration
  def change
    create_table :life_cycles do |t|
      t.string :name
      t.integer :min_daily_volume
      t.integer :max_daily_volume
      t.integer :scribe_policy
      t.integer :pcr_policy
      t.integer :ma_policy
      t.integer :xray_policy
      t.integer :am_policy
      t.boolean :default

      t.timestamps
    end
  end
end
