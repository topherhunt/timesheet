require "test_helper"

class ProjectsControllerTest < ActionController::TestCase
  tests ProjectsController

  context "#index" do
    it "renders correctly" do
      user = create_signed_in_user
      project1 = create :project, user: user
      project2 = create :project, user: user, parent: project1

      get :index
      assert_equals 200, response.status
    end
  end

  context "#new" do
    it "renders correctly" do
      create_signed_in_user

      get :new
      assert_equals 200, response.status
    end
  end

  context "#create" do
    it "creates the invoice" do
      user = create_signed_in_user

      post :create, project: {name: "blah"}
      assert_equals 1, user.projects.count
      assert_redirected_to projects_path
    end
  end

  context "#show" do
    it "renders correctly" do
      user = create_signed_in_user
      project = create :project, user: user
      child = create :project, user: user, parent: project

      get :show, id: project.id
      assert_equals 200, response.status
    end
  end

  context "#edit" do
    it "renders correctly" do
      user = create_signed_in_user
      project = create :project, user: user

      get :edit, id: project.id
      assert_equals 200, response.status
    end
  end

  context "#update" do
    it "updates the project" do
      user = create_signed_in_user
      project = create :project, user: user

      patch :update, id: project.id, project: {rate: 75}
      assert_equals Money.new(7500), project.reload.rate
      assert_redirected_to projects_path
    end
  end

  context "#delete" do
    it "renders correctly" do
      user = create_signed_in_user
      project = create :project, user: user

      get :delete, id: project.id
      assert_equals 200, response.status
    end
  end

  context "#destroy" do
    it "destroys the project" do
      user = create_signed_in_user
      project = create :project, user: user
      project2 = create :project, user: user

      delete :destroy, id: project.id, move_to_project_id: project2.id
      assert_equals 1, user.projects.count
      assert_redirected_to projects_path
    end
  end
end
