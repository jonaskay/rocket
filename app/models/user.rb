class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :client, optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :client, presence: true, if: :client_admin?
end
