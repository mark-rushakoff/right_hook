$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'captain_hook'
require 'captain_hook/app'

require_relative './support/spec_helpers.rb'

RSpec.configure do |c|
  c.include CaptainHook::SpecHelpers
end
