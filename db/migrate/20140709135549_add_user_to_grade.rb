class AddUserToGrade < ActiveRecord::Migration
  def change
    add_reference :grades, :user, index: true
  end
end
