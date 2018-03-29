require "test_helper"

class UsersControllerTest < ActionController::TestCase
  tests UsersController

  context "#show" do
    it "renders correctly" do
      user = create_signed_in_user

      get :show, id: "blah"
      assert_equals 200, response.status
    end
  end
end
