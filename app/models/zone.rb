class Zone < ActiveRecord::Base
  has_many :locations
  has_many :memberships
  has_many :users, through: :memberships

  scope :ordered, -> { order(name: :asc) }

  default_scope -> { order(name: :asc) }

  def to_s
    name
  end
end
