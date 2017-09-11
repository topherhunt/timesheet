require "test_helper"

class ProjectsTest < Capybara::Rails::TestCase
  setup do
    @user = create :user
  end

  test "user can create a project" do
    login_as @user
    visit projects_path
    page.find('.test-new-project').click
    fill_in "project[name]", with: "P1"
    click_button "Save"
    assert_equals "P1", @user.projects.first.name
  end

  test "user can delete a project" do
    @p0 = create :project, user: @user
    @p1 = create :project, user: @user
    @p2 = create :project, user: @user
    @p3 = create :project, user: @user, parent: @p2
    @e1 = create :work_entry, user: @user, project: @p2
    @i1 = create :invoice, user: @user, project: @p2

    assert_equals 1, @p2.children.count
    assert_equals 1, @p2.work_entries.count
    assert_equals 1, @p2.invoices.count

    login_as @user
    visit projects_path
    page
      .find("tr[data-project-id=\"#{@p2.id}\"]")
      .find(".test-delete-project")
      .click
    assert_equals delete_project_path(@p2), current_path
    select @p1.name_with_ancestry, from: "move_to_project_id"
    click_button "Destroy this project and move its data"
    assert_content "Project \"#{@p2.name_with_ancestry}\" has been removed."

    assert_equals 0, @p2.children.count
    assert_equals 0, @p2.work_entries.count
    assert_equals 0, @p2.invoices.count
    assert_equals 1, @p1.children.count
    assert_equals 1, @p1.descendants.count # ensure closure_tree hierarchy rebuilt
    assert_equals 1, @p1.work_entries.count
    assert_equals 1, @p1.invoices.count
  end
end
