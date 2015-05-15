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
end