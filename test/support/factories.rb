FactoryBot.define do
  factory :user do
    sequence(:email)      { |n| "test_user_#{n}@example.com" }
    password              { "password" }
    password_confirmation { "password" }
  end

  factory :project do
    user
    sequence(:name) { |n| "Project #{n}" }
    start_date { Date.current - rand(0..100) }
  end

  factory :work_entry do
    user
    project
    started_at { (rand * 1000).hours.ago }
    duration { rand * 3 }
    invoice_notes { %w(on to the work completing interface design plan implement refactor page rewrite rethink discuss review test troubleshoot fixes).shuffle.take(rand(3..8)).join(" ") }
  end

  factory :invoice do
    user
    project
    total_bill { Money.new(rand(100_00..4000_00)) }
    date_start { 15.days.ago }
    date_end { 1.day.ago }
    total_hours { rand * 50 }
  end
end
