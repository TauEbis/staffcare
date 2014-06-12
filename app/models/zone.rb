class Zone < ActiveRecord::Base
  has_many :locations
  has_many :memberships
  has_many :users, through: :memberships

  def to_s
    name
  end
end
