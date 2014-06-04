class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :zone
end
