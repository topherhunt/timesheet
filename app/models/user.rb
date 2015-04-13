class User < ActiveRecord::Base
  has_many :clients
  has_many :projects

  # Other Devise modules: :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
