class TodoNotices < ActionMailer::Base
  default from: "no-reply@staffcare.citymd.net"
  helper :application

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.todo_notices.missed.subject
  #
  def missed(user, todos)
    @user = user
    @todos = todos
    mail to: user.email, subject: "[StaffCare] You have missed some todos"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.todo_notices.waiting.subject
  #
  def waiting(user)
    @user = user
    @todos = todos

    mail to: user.email, subject: "[StaffCare] You have new todos waiting"
  end
end
