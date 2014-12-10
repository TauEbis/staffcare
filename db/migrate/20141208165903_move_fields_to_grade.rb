class MoveFieldsToGrade < ActiveRecord::Migration
  def change
    add_column :grades, :location_id, :integer
    add_column :grades, :schedule_id, :integer
    add_column :grades, :visit_projection_id, :integer
    add_column :grades, :visits,      :json
    add_column :grades, :max_mds,     :integer
    add_column :grades, :rooms,       :integer
    add_column :grades, :min_openers, :integer
    add_column :grades, :min_closers, :integer
    add_column :grades, :open_times,  :integer, array: true, default: []
    add_column :grades, :close_times, :integer, array: true, default: []
    add_column :grades, :optimizer_state, :integer, default: 0, null: false
    add_column :grades, :optimizer_job_id, :string
    add_column :grades, :normal, :decimal, precision: 8, scale: 4, default: [], null: false, array: true
    add_column :grades, :max,    :decimal, precision: 8, scale: 4, default: [], null: false, array: true
  end
end
