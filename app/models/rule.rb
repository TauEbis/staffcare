# A rule is a used to generate non-physician employee staffing schedules for a grade
class Rule < ActiveRecord::Base

  belongs_to :position
  belongs_to :grade

  scope :template, -> { where(grade_id: nil) }
  scope :ordered, -> { order(position_id: :asc) }
  scope :am, -> { where( position: Position.where(key: :am) ) }
  scope :ma, -> { where( position: Position.where(key: :ma) ) }
  scope :manager, -> { where( position: Position.where(key: :manager) ) }
  scope :pcr, -> { where( position: Position.where(key: :pcr) ) }
  scope :scribe, -> { where( position: Position.where(key: :scribe) ) }
  scope :xray, -> { where( position: Position.where(key: :xray) ) }
  scope :line_workers, -> { where( position: Position.line_workers ) } # nil positions keys not included

  default_scope -> { ordered }

  validates :name, presence: true
  validates :position, uniqueness: { scope: :grade }, presence: true

  enum name: [:limit_1, :limit_1_5, :limit_2, :ratio_1, :ratio_1_5, :ratio_2, :step_md, :step_pat, :salary]
  #after_initialize :set_default_name, :if => :new_record? -- commented out since set by database to :limit_1

  # Once this method is run the template will be editable via the index action
  def self.create_default_template

    default_template = {
      am:         { name: :salary  },
      ma:         { name: :limit_1  },
      manager:    { name: :salary   },
      pcr:        { name: :ratio_1  },
      scribe:     { name: :ratio_2  },
      xray:       { name: :limit_1  }
    }

    default_template.each do |k, v|
      p = Position.find_by(key: k)
      if Rule.template.where(position: p).empty?
        r = p.rules.new
        r.send("#{v[:name]}!")
        Rule.set_default_params(r) if r.shift_space_params.empty? && r.step_params.empty?
        r.save
      end
    end

  end

  def self.copy_template_to_grade(new_grade)
    Rule.template.each do |rule|
      r = rule.dup
      r.position = rule.position
      r.grade = new_grade
      r.save!
    end
  end

  def self.set_default_params(rule)
    rule.shift_space_params = { staff_min: 1, staff_max: 2, shift_min: 6, shift_max: 12 }
    rule.step_params = { steps: [0, 0, 8, 12, -1] }
  end

# Collection for form
  NAME_OPTIONS = [
    'Single Coverage',
    'Average of One-and-a-half Coverage',
    'Double Coverage',
    '1 to 1 Physician Ratio',
    '1.5 to 1 Physician Ratio',
    '2 to 1 Physician Ratio',
    'Step-up by Physician',
    'Step-up by Patient',
    'Salary'
  ].zip(Rule::names.keys).freeze

  def label
    NAME_OPTIONS[Rule::names[self.name]][0]
  end

  #def to_s
  #  "#{name} (#{min_daily_volume}-#{max_daily_volume})#{'*' if default?}"
  #end

  #def options_to_display
  #end

end
