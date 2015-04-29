class WorkEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :project_id, presence: true
  validates :date,       presence: true

  scope :running, ->{ where "duration IS NULL" }

  def stop!
    raise "Entry #{id} is already stopped!" if duration.present?
    self.duration = ((Time.now - created_at) / 1.hour).round(2)
    save!
  end
end
