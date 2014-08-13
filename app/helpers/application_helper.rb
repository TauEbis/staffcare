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

  def datepicker_opts(overrides = {})
    {required: true, input_html: { data: {behaviour: "datepicker"}}, as: :string}.merge(overrides)
  end

  def deadline_label(user, location_plan)
    deadline = case user.role
                 when 'admin'
                   location_plan.schedule.sync_deadline
                 when 'gm'
                   location_plan.schedule.gm_deadline
                 when 'manager'
                   location_plan.schedule.manager_deadline
               end

    dist = deadline - Date.today
    label_class = if dist >= 3
                    'primary'
                  elsif dist > 0
                    'warning'
                  else
                    'danger'
                  end

    %{<span class="label label-#{label_class}">Due: #{l deadline}</span>}.html_safe
  end
end
