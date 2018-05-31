require "test_helper"

class WorkEntriesControllerTest < ActionController::TestCase
  tests WorkEntriesController

  context "#index" do
    it "renders correctly" do
      user = create_signed_in_user
      entry = create :work_entry, user: user

      get :index
      assert_equals 200, response.status
    end

    it "renders correctly when a filter is applied" do
      user = create_signed_in_user
      entry = create :work_entry, user: user

      get :index, filter: "Filter", on_or_after: "2018-04-03"
      assert_equals 200, response.status
    end
  end

  context "#create" do
    it "creates the work entry" do
      user = create_signed_in_user
      project = create :project, user: user

      post :create, work_entry: {project_id: project.id, invoice_notes: "blah"}
      assert_equals 1, user.work_entries.count
      assert_redirected_to work_entries_path
    end
  end

  context "#edit" do
    it "renders correctly" do
      user = create_signed_in_user
      entry = create :work_entry, user: user

      get :edit, id: entry.id
      assert_equals 200, response.status
    end
  end

  context "#update" do
    it "updates the work entry" do
      user = create_signed_in_user
      entry = create :work_entry, user: user

      patch :update, id: entry.id, work_entry: {
        duration: 5.2,
        started_at_date: (Date.current - 1).to_s,
        started_at_time: "3:00 pm"
      }
      assert_equals 5.2, entry.reload.duration
      assert_equals (Date.current - 1).beginning_of_day + 15.hours, entry.started_at
      assert_redirected_to work_entries_path
    end
  end

  context "#stop" do
    it "stops the work entry" do
      user = create_signed_in_user
      entry = create :work_entry, user: user,
        started_at: 4.hours.ago,
        duration: nil
      assert entry.running?

      patch :stop, id: entry.id
      assert entry.reload.stopped?
      assert_redirected_to work_entries_path
    end
  end

  def add_entry(user, project, started_at, attrs = {})
    create :work_entry,
      {user: user, project: project, started_at: started_at}.merge(attrs)
  end

  context "#prior_entry" do
    it "returns the prior entry for the same project and status" do
      user = create_signed_in_user
      project1 = create :project, user: user
      project2 = create :project, user: user
      entry1 = add_entry(user, project1, 5.days.ago)
      entry2 = add_entry(user, project1, 4.days.ago)
      entry3 = add_entry(user, project2, 3.days.ago)
      entry4 = add_entry(user, project1, 2.days.ago, exclude_from_invoice: true)
      entry5 = add_entry(user, project1, 1.days.ago)

      get :prior_entry, id: entry5.id
      assert_equals 200, response.status
      # - entry4 doesn't have the same billing status
      # - entry3 doesn't belong to the same project
      # - That leaves entry2 as the most recent entry of same status.
      assert_equals entry2.id, JSON.parse(response.body)["entry_id"]
    end
  end

  context "#merge" do
    it "returns the prior entry for the same project and status" do
      user = create_signed_in_user
      project = create :project, user: user
      entry1 = add_entry(user, project, 2.days.ago)
      entry2 = add_entry(user, project, 1.day.ago)
      assert_equals [entry1.id, entry2.id], user.work_entries.pluck(:id).sort

      post :merge, from: entry2.id, to: entry1.id
      assert_equals [entry1.id], user.work_entries.pluck(:id).sort
      assert_redirected_to work_entries_path
    end
  end

  context "#destroy" do
    it "destroys the work entry" do
      user = create_signed_in_user
      entry = create :work_entry, user: user

      delete :destroy, id: entry.id
      assert_equals 0, user.work_entries.count
      assert_redirected_to work_entries_path
    end
  end

  context "#download" do
    it "generates a CSV of all my entries" do
      user = create_signed_in_user
      entry = create :work_entry, user: user

      get :download
      assert_equals 200, response.status
    end
  end
end
