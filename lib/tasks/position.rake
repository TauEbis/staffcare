namespace :position do

  task :create => :environment do
    Position.create_key_positions
    puts "All standard positions created"
    Position.find_by(key: :md).shifts << Shift.where(position_id: nil)
    puts "Assigning un-assigned shifts to physician"
  end

end