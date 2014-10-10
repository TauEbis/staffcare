module ShiftsHelper
  def time_span(s, e)
    "#{l(s)} - #{l(e, format: :only_time)} ( #{(e-s) / 3600} hrs )"
  end
end
