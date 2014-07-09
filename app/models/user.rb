class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         #:zxcvbnable,
         :lockable, :timeoutable, :invitable

  enum role: [:nobody, :admin, :manager, :gm]
  after_initialize :set_default_role, :if => :new_record?

  has_many :memberships
  has_many :locations, through: :memberships
  #has_many :zones, -> { distinct }, through: :locations

  def label
    name.blank? ? email : name
  end

  def set_default_role
    self.role ||= :nobody
  end

  def admin?
    self.role == 'admin'
  end

  def zone_ids
    @_zone_ids ||= locations.select(:zone_id).distinct
  end

  def zones
    @_zones ||= Zone.where(id: zone_ids)
  end

end
