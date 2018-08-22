
source 'https://rubygems.org'
ruby '2.5.1'

gem 'rails', '~> 4.2.10'
gem 'mysql2', '~> 0.4.10' # 0.5 is incompatible with Rails 4.2, or something
gem 'figaro'
gem 'lograge'
gem 'rollbar'
gem 'unicorn'

gem 'bcrypt'
gem 'closure_tree'
gem 'devise'
gem 'money-rails'
gem 'nokogiri'
gem 'will_paginate'

gem 'bootstrap-sass'
gem 'bootstrap-will_paginate'
gem 'coffee-rails'
gem 'font-awesome-rails'
gem 'haml-rails'
gem 'jquery-rails'
gem 'sass-rails'
gem 'uglifier'

group :development do
  gem 'web-console'
end

group :development, :test do
  gem 'bullet' # detect N+1 sql queries
  # gem 'sql-logging' # get stacktrace for source of each SQL query
  gem 'minitest-rails'
  gem 'm' # run all or part of test suite using `m path/to/test_file.rb:line`
  gem 'factory_bot'
  gem 'launchy' # for save_and_open_page
  gem 'pry'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end

group :test do
  gem 'capybara-webkit'
  gem 'maxitest' # Rspec-like aliases; colorful test output
  gem 'minitest-rails-capybara'
  gem 'mocha'
  gem 'timecop'
end

group :production do
  gem 'rails_12factor'
  gem 'rack-timeout' # for easier debugging of timed-out requests
end
