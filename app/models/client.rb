class Client < ActiveRecord::Base
  belongs_to :user
  has_many :projects

  validates :user_id, presence: true
  validates :name,    presence: true
end
