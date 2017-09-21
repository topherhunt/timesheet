
source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '~> 4.2.0'
gem 'mysql2'
gem 'figaro'
gem 'rollbar'
gem 'unicorn'

gem 'bcrypt-ruby'
gem 'closure_tree'
gem 'devise'
gem 'money-rails'
gem 'nokogiri', '1.6.7.2' # Compile errors on 1.6.8
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
  gem 'bullet'
  gem 'minitest-rails'
  gem 'm' # run all or part of test suite using `m path/to/test_file.rb:line`
  gem 'factory_girl'
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
