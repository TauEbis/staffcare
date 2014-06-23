class AddDetailsToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, 'penalty_30min', :decimal, precision: 8, scale: 4, null: false
    add_column :schedules, 'penalty_60min', :decimal, precision: 8, scale: 4, null: false
    add_column :schedules, 'penalty_90min', :decimal, precision: 8, scale: 4, null: false
    add_column :schedules, 'penalty_eod_unseen',  :decimal, precision: 8, scale: 4, null: false
    add_column :schedules, 'penalty_slack',    :decimal, precision: 8, scale: 4, null: false
    add_column :schedules, 'min_openers', :integer, null: false
    add_column :schedules, 'min_closers', :integer, null: false
    add_column :schedules, 'md_rate', :decimal, precision: 8, scale: 4, null: false
    add_column :schedules, :oren_shift, :boolean, null: false, default: false
  end
end
