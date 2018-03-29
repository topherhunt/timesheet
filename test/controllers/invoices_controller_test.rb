require "test_helper"

class InvoicesControllerTest < ActionController::TestCase
  tests InvoicesController

  context "#index" do
    it "renders correctly" do
      user = create_signed_in_user
      invoice = create :invoice, user: user

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

  context "#preview" do
    it "renders correctly" do
      user = create_signed_in_user
      project = create :project, user: user
      entry = create :work_entry, user: user, project: project

      get :preview,
        project_id: entry.project_id,
        date_start: entry.started_at.to_date - 10,
        date_end: entry.started_at.to_date + 10
      assert_equals 200, response.status
    end
  end

  context "#create" do
    it "creates the invoice" do
      user = create_signed_in_user
      entry = create :work_entry, user: user

      post :create, invoice: {
        project_id: entry.project.id,
        date_start: entry.started_at.to_date - 10,
        date_end: entry.started_at.to_date + 10
      }
      assert_equals 1, user.invoices.count
      assert_redirected_to invoices_path
    end
  end

  context "#show" do
    it "renders correctly" do
      user = create_signed_in_user
      entry = create :work_entry, user: user
      invoice = create :invoice,
        user: user,
        project: entry.project,
        date_start: 1.year.ago,
        date_end: Date.current + 1

      get :show, id: invoice.id
      assert_equals 200, response.status
    end
  end

  context "#update" do
    it "updates the invoice" do
      user = create_signed_in_user
      invoice = create :invoice, user: user, is_sent: false

      patch :update, id: invoice.id, invoice: {is_sent: true}
      assert invoice.reload.is_sent?
      assert_redirected_to invoices_path
    end
  end

  context "#destroy" do
    it "destroys the invoice" do
      user = create_signed_in_user
      invoice = create :invoice, user: user

      delete :destroy, id: invoice.id
      assert_equals 0, Invoice.where(id: invoice.id).count
      assert_redirected_to invoices_path
    end
  end

  context "#download" do
    it "generates a CSV of all my invoices" do
      user = create_signed_in_user
      invoice = create :invoice, user: user

      get :download
      assert_equals 200, response.status
    end
  end
end
