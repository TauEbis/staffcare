class CreatePushes < ActiveRecord::Migration
  def change
    create_table :pushes do |t|
      t.references :location_plan, index: true
      t.json :theory, default: {}, null: false
      t.json :log, default: {}, null: false

      t.timestamps
    end
  end
end
