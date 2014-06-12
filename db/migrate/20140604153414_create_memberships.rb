class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :user, index: true, null: false
      t.references :zone, index: true, null: false

      t.timestamps
    end
  end
end
