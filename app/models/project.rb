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
    rate_cents = self_and_ancestors.pluck(:rate_cents).reject{ |v| v == 0 }.first
    Money.new(rate_cents || 0)
  end

  def name_with_ancestry
    self_and_ancestors.pluck(:name).reverse.join(": ")
  end
end
