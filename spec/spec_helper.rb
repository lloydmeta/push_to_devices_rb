require 'bundler/setup'
require 'rspec'
require 'push_to_devices'
require 'webmock/rspec'
require 'json'

Dir[File.expand_path('../support/**/*', __FILE__)].each { |f| require f }

RSpec.configure do |config|

  config.before(:each) do
    WebMock.reset!
    WebMock.disable_net_connect!
    stub_request(:any, /.*/).to_return(:body => {status: "ok"}.to_json)
  end

end