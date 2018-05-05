class Project < ActiveRecord::Base
  has_closure_tree # See https://github.com/ClosureTree/closure_tree

  belongs_to :user
  has_many :work_entries
  has_many :invoices

  validates :user_id,   presence: true
  validates :name,      presence: true

  scope :active,     -> { where active: true   }
  scope :paying,     -> { where 'rate_cents > 0' }

  monetize :rate_cents, allow_nil: true

  def inherited_rate
    with_cache("inherited_rate") do
      rate_cents = self_and_ancestors.pluck(:rate_cents).reject{ |v| v == 0 }.first
      Money.new(rate_cents || 0)
    end
  end

  def billable?
    inherited_rate > 0
  end

  def name_with_ancestry
    with_cache("name_with_ancestry") do
      self_and_ancestors.pluck(:name).reverse.join(": ")
    end
  end

  def self_and_descendant_ids
    with_cache("self_and_descendant_ids") do
      self_and_descendants.pluck(:id)
    end
  end

  # Note that summing doesn't make sense if a parent and child both have targets.
  def sum_target
    with_cache("sum_target") do
      self_and_descendants.sum(:weekly_target)
    end
  end

  def with_cache(suffix, &block)
    Cacher.fetch("user_#{user_id}_project_#{id}_#{suffix}", &block)
  end
end
