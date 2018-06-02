ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/rails/capybara"
require "mocha/minitest"
require "maxitest/autorun"
require "bcrypt"
require "support/factories"
require 'support/global_helpers'
require 'support/controller_helpers'
require 'support/feature_helpers'
