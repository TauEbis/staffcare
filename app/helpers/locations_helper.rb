module LocationsHelper
  def hours_options
    @_hours_options ||= begin
      m = 0
      buf = []
      (6..24).each do |h|
        if h == 24
          buf << [sprintf("%02i:%02i am", h-12, m), h*60 + m]
        elsif h == 12
            buf << [sprintf("%02i:%02i pm", h, m), h*60 + m]
        elsif h < 12
          buf << [sprintf("%02i:%02i am", h, m), h*60 + m]
        else
          buf << [sprintf("%02i:%02i pm", h-12, m), h*60 + m]
        end
      end

      buf
    end
  end
end
