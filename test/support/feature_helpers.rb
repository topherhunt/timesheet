class Capybara::Rails::TestCase
  Capybara.javascript_driver = :webkit

  def login_as(user, password = 'password')
    visit new_user_session_path
    assert_content "Log in"
    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"
    assert_content "Log out"
  end

  def logout
    visit "/logout"
  end

  def page!
    save_and_open_page
  end

  def using_webkit(&block)
    begin
      Capybara.current_driver = :webkit
      yield
    ensure
      Capybara.use_default_driver
    end
  end

  # Use Jquery to force display a hidden element. Useful for getting at links
  # that are dynamically displayed: js_show("#hidden-div")
  def js_show(selector)
    page.execute_script(" $('#{selector}').show(); ")
  end

  def js_hide(selector)
    page.execute_script(" $('#{selector}').hide(); ")
  end

  # See https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until page.evaluate_script('jQuery.active').zero?
    end
  end

  def assert_path(path)
    10.times do
      return if current_path == path
      sleep 0.2
    end
    raise "Expected current_path to be \"#{path}\", but was \"#{current_path}\"!"
  end

  def assert_users_cant_access_pages(opts)
    opts.fetch(:users).each do |user|
      logout
      login_as(user)
      opts.fetch(:pages).each do |path|
        visit path
        assert_text "not authorized"
        assert_not_equal path, current_path
      end
    end
  end
end
