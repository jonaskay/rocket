class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :master_trainings, foreign_key: :trainer_id, dependent: :destroy
  belongs_to :client, optional: true

  generates_token_for :password_reset, expires_in: 72.hours do
    password_salt&.last(10)
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :client, presence: true, unless: :super_admin?
  validates :first_name, presence: true, unless: :super_admin?
  validates :last_name, presence: true, unless: :super_admin?

  enum :status, { active: 0, inactive: 1, pending_password_change: 2 }, default: :active

  scope :trainers, -> { where(client_admin: false, super_admin: false) }

  def trainer?
    !super_admin? && !client_admin?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def password_reset_token_expires_in
    72.hours
  end
end
