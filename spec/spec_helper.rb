$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'right_hook'
require 'right_hook/app'
require 'right_hook/authenticated_client'
require 'right_hook/authenticator'
require 'right_hook/commenter'
require 'right_hook/subscriber'

require_relative './support/spec_helpers.rb'

require 'webmock/rspec'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |c|
  c.include RightHook::SpecHelpers
end
