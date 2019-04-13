ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] = File.expand_path("../dummy", __FILE__)
require_relative "dummy/config/environment"

require "apitome"

require "rspec/rails"
require "capybara/rails"
require "aruba/api"

# require "fileutils"
# require "ostruct"

# Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }


def register_driver(name, args = [], opts = {})
  Capybara.register_driver(name) do |app|
    options = { args: args + ["window-size=1440,1080"] }
    options[:binary] = ENV.fetch("GOOGLE_CHROME_SHIM", nil)
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: options.compact)
    Capybara::Selenium::Driver.new(app, { browser: :chrome, desired_capabilities: capabilities }.merge(opts))
  end
end

register_driver(:chrome)
register_driver(:chrome_headless, %w[headless disable-gpu no-sandbox disable-dev-shm-usage])

RSpec.configure do |config|
  config.order = "random"
  # config.include Rack::Test::Methods
  config.include Aruba::Api

  config.before(:each, shell: true) do
    @aruba_timeout_seconds = 180
    setup_aruba
  end

  config.before(:each, browser: true) do
    Capybara.default_driver = Capybara.javascript_driver = ENV.fetch("CAPYBARA_DRIVER", "chrome_headless").to_sym
  end
end
