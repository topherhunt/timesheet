require 'rails_helper'

describe "Devise" do
  example "user registers an account" do
    visit root_path
    click_link "Sign up"

    fill_in 'user_email',                 with: "elmer.fudd@gmail.com"
    fill_in 'user_password',              with: "foobar01"
    fill_in 'user_password_confirmation', with: "foobar01"
    click_button "Sign up"

    page.should have_link "Log out"
    page.should_not have_link "Sign up"
    page.should have_content "elmer.fudd@gmail.com"
  end

  example "user logs in, changes password, and logs out" do
    user = create :user
    visit root_path

    click_link "Log in"
    fill_in 'user_email',    with: user.email
    fill_in 'user_password', with: user.password
    click_button "Log in"
    page.should_not have_link "Log in"
    page.should have_link "Log out"

    click_link "Account settings"
    fill_in 'user_password',              with: 'foobar02'
    fill_in 'user_password_confirmation', with: 'foobar02'
    fill_in 'user_current_password',      with: user.password
    click_button "Update"
    page.should have_content "Your account has been updated successfully."

    click_link "Log out"
    page.should have_link "Log in"
    page.should_not have_link "Log out"
  end
end