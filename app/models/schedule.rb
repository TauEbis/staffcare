class Schedule < ActiveRecord::Base

  enum state: [ :draft, :active, :published, :archived ]

  scope :not_draft, -> { where("state <> ?", Schedule.states[:draft]) }
  scope :ordered, -> { order(starts_on: :desc) }

  default_scope -> { order(starts_on: :desc) }

  OPTIMIZER_FIELDS = [:penalty_30min, :penalty_60min, :penalty_90min, :penalty_eod_unseen, :penalty_slack, :min_openers, :min_closers, :md_rate, :oren_shift]

  OPTIMIZER_FIELDS.each do |field|
    validates field, presence: true
  end

  validates :starts_on, presence: true

  def self.default_attributes
    {
      penalty_30min: 1,
      penalty_60min: 4,
      penalty_90min: 16,
      penalty_eod_unseen: 2,
      penalty_slack: 2.5,
      min_openers: 2,
      min_closers: 1,
      md_rate: 4.25,
      oren_shift: true
    }
  end

  def ends_on
    @_ends_on ||= starts_on + 27
  end

  def days
    @_days ||= begin
      b = Array.new

      for i in 0..28 do
        b << starts_on + i
      end

      b
    end
  end
end
