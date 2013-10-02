require 'right_hook'
require 'right_hook/app'
require 'right_hook/authenticated_client'
require 'right_hook/authenticator'
require 'right_hook/commenter'
require 'right_hook/event'
require 'right_hook/spec_helpers'
require 'right_hook/subscriber'

require 'webmock/rspec'
require 'rack/test'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |c|
  c.include Rack::Test::Methods
  c.include RightHook::SpecHelpers
end
