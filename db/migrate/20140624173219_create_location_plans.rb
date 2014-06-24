class CreateLocationPlans < ActiveRecord::Migration
  def change
    create_table :location_plans do |t|
      t.references :location, null: false
      t.references :schedule, null: false
      t.references :visit_projection, null: false

      t.json :visits

      t.integer :approval_state, null: false, default: 0
      t.references :chosen_grade

      t.integer :max_mds
      t.integer :rooms
      t.integer :min_openers
      t.integer :min_closers

      t.integer :open_times,  array: true, default: []
      t.integer :close_times, array: true, default: []
    end
  end
end
