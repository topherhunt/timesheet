ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

# See additional helpers & config in support/
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
  # This makes #sign_in and #sign_out available in controller specs
  config.include Devise::TestHelpers, type: :controller
end
