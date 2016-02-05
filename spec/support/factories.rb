FactoryGirl.define do
  factory :user do
    sequence(:email)      { |n| "test_user_#{n}@example.com" }
    password              "foobar01"
    password_confirmation "foobar01"
  end

  factory :client do
    user
    name "Some Client"
  end

  factory :project do
    user
    client
    name "Some Project"
  end

  factory :work_entry do
    user
    project

    date     Date.today
    duration 1
  end

  factory :invoice do
    user
    client
    rate Money.new(4500)
    date_start 15.days.ago
    date_end 1.day.ago
    total_hours 21.2
  end
end
