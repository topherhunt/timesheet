require "#{Rails.root}/test/support/factories.rb"

User.delete_all
Project.delete_all
WorkEntry.delete_all
Invoice.delete_all

@topher = FactoryGirl.create :user, email: "hunt.topher@gmail.com"

@projects = [nil]
10.times do
  project = FactoryGirl.create :project, user: @topher, parent: @projects.sample
  @projects << project
  rand(5..50).times do
    FactoryGirl.create :work_entry, user: @topher, project: project
  end
end

puts "Database is seeded!"
puts "- #{User.count} users"
puts "- #{Project.count} projects"
puts "- #{WorkEntry.count} work entries"
