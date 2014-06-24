class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.references :location_plan, null: false

      t.json :coverages, null: false, default: {}
      t.json :penalties, null: false, default: {}
      t.json :points,    null: false, default: {}
    end
  end
end
