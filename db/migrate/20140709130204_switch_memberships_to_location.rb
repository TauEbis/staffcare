class SwitchMembershipsToLocation < ActiveRecord::Migration

  # Permissions will need to be re-setup for users
  def change
    Membership.delete_all
    remove_column :memberships, :zone_id
    add_column :memberships, :location_id, :integer, index: true, null: false
  end
end
