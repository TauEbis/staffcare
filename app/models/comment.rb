class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :location_plan
  belongs_to :grade

  validates :user_id, presence: true
  validates :location_plan_id, presence: true

  scope :ordered, -> { order('created_at DESC') }

  enum cause: [:comment, :state_changed, :copied, :edited, :deleted]

  def timestamp
    I18n.localize(created_at, format: :default)
  end

  def user_name
    user.try(:label)
  end

  def user_avatar_url
    user.try(:avatar_url)
  end
end
