module LocationsHelper
  def hours_options
    @_hours_options ||= begin
      mins = [0,15,30,45]
      buf = []
      (0...24).each do |h|
        mins.each do |m|
          if h <= 12
            buf << [sprintf("%02i:%02i am", h, m), h*60 + m]
          else
            buf << [sprintf("%02i:%02i pm", h-12, m), h*60 + m]
          end
        end
      end

      buf
    end
  end
end
