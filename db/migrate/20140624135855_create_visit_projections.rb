class CreateVisitProjections < ActiveRecord::Migration
  def change
    create_table :visit_projections do |t|
      t.references :schedule, null: false
      t.references :location, null: false

      t.string :source

      t.json :heat_maps
      t.json :volumes
      t.json :visits

      t.timestamps
    end
  end
end
