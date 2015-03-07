Rails.application.config.after_initialize do
  Holidays.load_custom("./lib/holiday_definitions/citymd_holidays.yaml")
  y = Date.today.year
  Schedule::HOLIDAYS = Holidays.between(Date.civil(y-5, 1,1), Date.civil(y+5, 12,31), :citymd)
end