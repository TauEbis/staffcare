class Float
  def to_time_of_day
    h = self
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
end
