class Schedule < ActiveRecord::Base

  enum state: [ :draft, :active, :published, :archived ]

  scope :not_draft, -> { where("state <> ?", Schedule.states[:draft]) }
end
