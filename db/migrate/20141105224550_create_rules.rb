
class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
    	t.integer :name, default: 0, null: false
      t.references :grade, index: true
      t.references :position, index: true
      t.json :shift_space_params, default: {}, null: false
      t.json :step_params, default: {}, null: false
    end
  end
end
