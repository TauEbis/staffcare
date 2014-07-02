class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.references :location_plan, null: false

      t.integer :source, null: false, default: 0

      t.json :grades, null: false, default: {}
      t.json :penalties, null: false, default: {}
      t.json :points,    null: false, default: {}

      t.timestamps
    end
  end
end
