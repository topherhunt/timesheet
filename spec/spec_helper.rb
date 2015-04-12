# Keep this file as light-weight as possible.
# More info: http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 3
  config.fail_fast = true
  config.mock_framework = :mocha
end
