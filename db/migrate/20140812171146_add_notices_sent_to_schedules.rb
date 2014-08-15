class AddNoticesSentToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :active_notices_sent_at, :datetime
  end
end
