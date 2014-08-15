class TodoNotifier

  # Sends notifications for all missed todos
  def self.missed!
    send_missed(:manager)
    send_missed(:gm)
  end

  def self.notify!
    User.find_each do |user|
      send_notice(user)
    end
  end

  def self.send_missed(role)
    Schedule.where("#{role}_deadline" => Date.yesterday).find_each do |schedule|
      Rails.logger.warn "Sending Missed Notices for #{role} on Schedule ##{schedule.id}"
      User.send(role).find_each do |user|
        send_notice(user)
      end
    end
  end

  def self.send_notice(user)
    todos = TodoPresenter.new(user)
    lps = todos.location_plans
    unless lps.blank?
      Rails.logger.warn "Sending Missed Notices to: #{user.email}"
      TodoNotices.missed(user, lps).deliver
    end
  end
end
