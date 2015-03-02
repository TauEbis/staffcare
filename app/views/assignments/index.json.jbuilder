json.extract! @schedule, :id, :days

json.location_plans @schedule.location_plans do |location_plan|
  json.id location_plan.id
  json.name location_plan.name
  json.chosen_grade_id location_plan.chosen_grade_id
  if @shifts[location_plan.id]
    json.days @shifts[location_plan.id].keys do |day|
      json.date day
      json.shifts @shifts[location_plan.id][day] do |shift|
        json.id shift.id
        json.starts_hour shift.starts_hour
        json.ends_hour shift.ends_hour
        json.physician_initials 'UN'
      end
    end
  end
end
