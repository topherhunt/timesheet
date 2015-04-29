class User < ActiveRecord::Base
  has_many :clients
  has_many :projects
  has_many :work_entries

  # Other Devise modules: :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def last_project
    work_entries.last.try(:project)
  end
end
