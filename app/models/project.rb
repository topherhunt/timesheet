class Project < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, class_name: 'Project', inverse_of: :children
  has_many :children, class_name: 'Project', foreign_key: 'parent_id', inverse_of: :parent
  has_many :work_entries
  has_many :invoices

  validates :user_id,   presence: true
  validates :name,      presence: true

  scope :top_level,  -> { where parent_id: nil }
  scope :active,     -> { where active: true   }
  scope :paying,     -> { where 'rate_cents > 0' }

  monetize :rate_cents, allow_nil: true

  def inherited_rate
    @inherited_rate ||=
      if rate > 0
        rate
      else
        parent.try(:inherited_rate) || rate
      end
  end

  def my_and_children_ids
    @my_and_children_ids ||= [id] + children.map(&:my_and_children_ids)
  end

  def my_and_children_entries
    WorkEntry.where(project_id: my_and_children_ids)
  end

  def name_with_ancestry
    @name_with_ancestry ||= if parent.present?
      "#{parent.name_with_ancestry}: #{name}"
    else
      name
    end
  end
end
