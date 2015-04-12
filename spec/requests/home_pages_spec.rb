require 'rails_helper'

describe "Home pages" do
  it "work and are linked up properly" do
    visit home_path
    page.should have_content "Welcome to VanillaApp!"

    click_link "About"
    page.should have_content "About Us"
  end
end