ENV["RAILS_ENV"] = "test"

require "rails"
require "rails/test_help"
require "slotify"

class TestApp < Rails::Application
  config.root = __dir__
  config.hosts << "slotify.build"
  credentials.secret_key_base = "slotify_secret_key"
end

require "support/view_helpers"

require "capybara/rails"
require "capybara/dsl"
require "capybara/minitest"
require "capybara/minitest/spec"

require "minitest/spec"
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class Slotify::TestCase < ActionView::TestCase
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  TestController.prepend_view_path "test/fixtures"
  TestController.prepend ViewHelpers

  private

  def page
    @page ||= Capybara.string(rendered)
  end
end
