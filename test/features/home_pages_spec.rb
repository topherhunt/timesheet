require "test_helper"

class HomeTest < Capybara::Rails::TestCase
  test "home pages work and are linked up properly" do
    visit home_path
    assert_content "Welcome to WorkTracker!"
    click_link "About"
    assert_content "About Us"
  end
end
