module ApplicationHelper

  def full_title page_title
    base_title = 'StaffCare'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def schedule_date_options(schedule)
    (schedule.starts_on..schedule.ends_on).map{|d| [ l(d, format: :with_dow), d.iso8601 ] }
  end

  # Take a float like 21.5 and make it "9:30pm"
  def time_of_day(h)
    m = ((h - h.to_i) * 60).to_i

    if h == 24
      sprintf("%02i:%02i am", h-12, m)
    elsif h == 12
      sprintf("%02i:%02i pm", h, m)
    elsif h < 12
      sprintf("%02i:%02i am", h, m)
    else
      sprintf("%02i:%02i pm", h-12, m)
    end
  end

  # Accepts either a Time/DateTime/Date object
  # or a String (should be in iso8601) and ensures it's a Time object
  def cast_time(time_or_str)
    case time_or_str
      when String
        Time.zone.parse time_or_str
      else
        time_or_str
    end
  end
end
