module LocationsHelper
  def hours_options
    @_hours_options ||= begin
      (6..24).map do |h|
        [time_of_day(h), h*60]
      end
    end
  end

  def link_to_add_speed_fields(name, f)
    new_object = f.object.send(:speeds).new
    id = new_object.object_id
    fields = f.fields_for(:speeds, new_object, child_index: id) do |builder|
      render("speed_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
