class RenameGradePenalties < ActiveRecord::Migration
  def change
    rename_column :grades, :penalties, :breakdowns
  end
end
