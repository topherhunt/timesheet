class Project < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  has_many :work_entries

  validates :user_id,   presence: true
  validates :client_id, presence: true
  validates :name,      presence: true

  scope :active, ->{ where active: true }
end
