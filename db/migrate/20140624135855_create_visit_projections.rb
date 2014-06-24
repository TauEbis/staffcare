class CreateVisitProjections < ActiveRecord::Migration
  def change
    create_table :visit_projections do |t|
      t.references :schedule
      t.references :location

      t.json :heat_maps
      t.json :volumes
      t.json :visits
    end
  end
end
