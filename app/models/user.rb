class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         #:zxcvbnable,
         :lockable, :timeoutable, :invitable

  enum role: [:nobody, :admin, :scheduler]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :nobody
  end

  def admin?
    self.role == 'admin'
  end

end
