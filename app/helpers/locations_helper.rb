module LocationsHelper
  def hours_options
    @_hours_options ||= begin
      (6..24).map do |h|
        [time_of_day(h), h*60]
      end
    end
  end

  def link_to_add_speed_fields(link_text, f)
    new_object = f.object.send(:speeds).new
    id = new_object.object_id
    fields = f.fields_for(:speeds, new_object, child_index: id) do |builder|
      render("speed_fields", f: builder)
    end
    link_to(link_text, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def link_to_delete_speed(link_text, speed)
    if speed.id.nil?
      link_to(link_text, '#', class: "remove_fields")
    else
      link_to(link_text, speed_path(speed), class: "remove_fields_remote", method: :delete, remote: true)
    end
  end

end
