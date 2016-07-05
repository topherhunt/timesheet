require "test_helper"

class WorkEntriesTest < Capybara::Rails::TestCase
  setup do
    @user = create(:user)
    @project = create(:project, user: @user)
  end

  test "user can merge 2 work entries having the same project & status" do
    @entry1 = create :work_entry, user: @user, project: @project, date: "2015-05-19", duration: 2, invoice_notes: "abc"
    @entry2 = create :work_entry, user: @user, project: @project, date: "2015-05-20", duration: 1.5, invoice_notes: "def", admin_notes: "ghi"

    login_as(@user)
    visit edit_work_entry_path(@entry2)
    click_on "Merge with prior entry"
    assert_content "Merged entries #{@entry2.id} & #{@entry1.id}."
    assert_equals 1, WorkEntry.count
    @entry1.reload
    assert_equals 3.5, @entry1.duration
    assert_equals Date.parse("2015-05-19"), @entry1.date
    assert_equals "abc; def", @entry1.invoice_notes
    assert_equals "ghi", @entry1.admin_notes
  end
end
