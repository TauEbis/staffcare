namespace :position do

  task :create => :environment do
    Position.create_key_positions
    puts "All standard positions created"
    position_id = Position.find_by(key: :md).id
    Shift.where(position_id: :nil).update_all(position_id: position_id)
    puts "Assigning un-assigned shifts to physician"
  end

end