require "#{Rails.root}/test/support/factories.rb"

def create_random_projects_and_entries_for(user)
  projects = []
  4.times { projects << FactoryBot.create(:project, user: user, parent: nil) }
  6.times { projects << FactoryBot.create(:project, user: user, parent: projects.sample) }
  projects.each do |project|
    rand(5..20).times do
      FactoryBot.create :work_entry,
        user: user,
        project: project,
        exclude_from_invoice: (rand > 0.9)
    end
  end
end

User.delete_all
Project.delete_all
WorkEntry.delete_all
Invoice.delete_all

@topher = FactoryBot.create :user, email: "hunt.topher@gmail.com"
@user2  = FactoryBot.create :user

create_random_projects_and_entries_for(@topher)
create_random_projects_and_entries_for(@user2)
Project.rebuild!

# TODO: Need some invoices too.

puts "Database is seeded!"
puts "- #{User.count} users (#{User.all.pluck(:id, :email)})"
puts "- #{Project.count} projects"
puts "- #{WorkEntry.count} work entries"
