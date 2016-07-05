require "test_helper"

class AccountsTest < Capybara::Rails::TestCase
  test "user registers an account" do
    visit root_path
    click_link "Sign up"

    fill_in 'user_email',                 with: "elmer.fudd@gmail.com"
    fill_in 'user_password',              with: "foobar01"
    fill_in 'user_password_confirmation', with: "foobar01"
    click_button "Sign up"

    assert_content "Log out"
    refute_content "Sign up"
    assert_content "elmer.fudd@gmail.com"
  end

  test "user logs in, changes password, and logs out" do
    user = create :user
    visit root_path

    click_link "Log in"
    fill_in 'user_email',    with: user.email
    fill_in 'user_password', with: user.password
    click_button "Log in"
    refute_content "Log in"
    assert_content "Log out"

    click_link "Account settings"
    fill_in 'user_password',              with: 'foobar02'
    fill_in 'user_password_confirmation', with: 'foobar02'
    fill_in 'user_current_password',      with: user.password
    click_button "Update"
    assert_content "Your account has been updated successfully."

    click_link "Log out"
    assert_content "Log in"
    refute_content "Log out"
  end
end
