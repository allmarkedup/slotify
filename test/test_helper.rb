ENV["RAILS_ENV"] = "test"

require "rails"
require "action_view"
require "rails/test_help"

class TestApp < Rails::Application
  config.root = __dir__
  config.hosts << "example.com"
  credentials.secret_key_base = "foobar"
end

require "capybara/rails"
require "capybara/dsl"
require "capybara/minitest"
require "capybara/minitest/spec"

require "minitest/spec"
require "minitest/reporters"

require "slotify"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class Slotify::TestCase < ActionView::TestCase
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  TestController.prepend_view_path "test/fixtures"

   private

  def page
    @page ||= Capybara.string(rendered)
  end
end
