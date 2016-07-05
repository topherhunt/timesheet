FactoryGirl.define do
  factory :user do
    sequence(:email)      { |n| "test_user_#{n}@example.com" }
    password              "password"
    password_confirmation "password"
  end

  factory :project do
    user
    name "Some Project"
  end

  factory :work_entry do
    user
    project

    date Time.zone.now.to_date
    duration 1
  end

  factory :invoice do
    user
    project
    total_bill Money.new(45000)
    date_start 15.days.ago
    date_end 1.day.ago
    total_hours 21.2
  end
end
