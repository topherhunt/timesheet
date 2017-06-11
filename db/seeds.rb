require "#{Rails.root}/test/support/factories.rb"

def create_random_projects_and_entries_for(user)
  my_projects = [nil]
  10.times do
    project = FactoryGirl.create :project, user: user, parent: my_projects.sample
    my_projects << project
    rand(5..20).times do
      will_bill = (rand < 0.9)
      is_billed = (will_bill && rand < 0.8)
      FactoryGirl.create :work_entry,
        user: user,
        project: project,
        will_bill: will_bill,
        is_billed: is_billed
    end
  end
end

User.delete_all
Project.delete_all
WorkEntry.delete_all
Invoice.delete_all

@topher = FactoryGirl.create :user, email: "hunt.topher@gmail.com"
@user2  = FactoryGirl.create :user

create_random_projects_and_entries_for(@topher)
create_random_projects_and_entries_for(@user2)

# TODO: Need some invoices too.

puts "Database is seeded!"
puts "- #{User.count} users (#{User.all.pluck(:id, :email)})"
puts "- #{Project.count} projects"
puts "- #{WorkEntry.count} work entries"
