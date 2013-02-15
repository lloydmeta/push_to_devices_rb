require 'bundler/setup'
require 'rspec'
require 'push_to_device'
require 'webmock/rspec'
require 'active_support/core_ext'

Dir[File.expand_path('../support/**/*', __FILE__)].each { |f| require f }

RSpec.configure do |config|

  config.before(:each) do
    WebMock.reset!
    WebMock.disable_net_connect!
    stub_request(:any, /.*/).to_return(:body => {status: "ok"}.to_json)
  end

end