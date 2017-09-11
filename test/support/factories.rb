FactoryGirl.define do
  factory :user do
    sequence(:email)      { |n| "test_user_#{n}@example.com" }
    password              "password"
    password_confirmation "password"
  end

  factory :project do
    user
    sequence(:name) { |n| "Project #{n}" }
  end

  factory :work_entry do
    user
    project

    date { rand(0..30).days.ago.to_date }
    duration { rand * 3 }
    invoice_notes { %w(work on completing interface design plans implement refactors to the page).shuffle.take(5).join(" ") }
  end

  factory :invoice do
    user
    project
    total_bill { Money.new(rand(100_00..4000_00)) }
    date_start 15.days.ago
    date_end 1.day.ago
    total_hours { rand * 50 }
  end
end
