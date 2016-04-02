class Client < ActiveRecord::Base
  belongs_to :user
  has_many :projects
  has_many :invoices

  validates :user_id, presence: true
  validates :name,    presence: true

  monetize :rate_cents, allow_nil: true
end
