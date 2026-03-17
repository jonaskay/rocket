class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :client, optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :client, presence: true, if: :client_admin?

  enum :status, { active: 0, inactive: 1, pending_password_change: 2 }, default: :active

  scope :trainers, -> { where(client_admin: false, super_admin: false) }
end
