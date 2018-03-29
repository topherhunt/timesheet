require "test_helper"

class HomeControllerTest < ActionController::TestCase
  tests HomeController

  def assert_signed_in_as(user)
    assert_equals user.id, warden.user.id
  end

  context "#home" do
    it "renders correctly" do
      get :home
      assert_equals 200, response.status
    end
  end

  context "#about" do
    it "renders correctly" do
      get :about
      assert_equals 200, response.status
    end
  end

  context "#error" do
    it "raises an exception for testing" do
      assert_raises(RuntimeError) { get :error }
    end
  end

  context "#login_as" do
    it "logs admin in as another user" do
      user1 = create :user
      user2 = create :user
      ENV['ADMIN_USER_IDS'] = "99999,#{user1.id}"

      sign_in user1
      get :login_as, user_id: user2.id
      assert_signed_in_as(user2)
    end

    it "rejects non-admin" do
      user1 = create :user
      user2 = create :user
      ENV['ADMIN_USER_IDS'] = "99998,99999"

      sign_in user1
      assert_raises(RuntimeError) { get :login_as, user_id: user2.id }
    end
  end
end
