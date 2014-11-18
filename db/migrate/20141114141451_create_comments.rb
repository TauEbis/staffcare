class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :user, index: true
      t.references :location_plan
      t.references :grade, index: true
      t.integer :cause, null: false, default: 0
      t.text :body
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :comments, [:location_plan_id, :created_at]
  end
end
