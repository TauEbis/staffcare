class Zone < ActiveRecord::Base
  has_many :locations

  def to_s
    name
  end
end
