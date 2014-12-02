class DropLifeCycles < ActiveRecord::Migration
  def change
  	drop_table :life_cycles
  end
end
