require 'spec_helper'
require 'rack/test'

describe RightHook::App do
  include Rack::Test::Methods

  class BareApp < RightHook::App
    def secret(owner, repo_name, event_type)
      ''
    end
  end

  def app
    BareApp
  end

  it 'is status 501 for a non-implemented hook' do
    post '/hook/mark-rushakoff/right_hook/issue', '{}', generate_secret_header('secret', '{}')
    expect(last_response.status).to eq(501)
  end

  it 'is 404 for an unknown hook' do
    post '/hook/mark-rushakoff/right_hook/foobar', '{}', generate_secret_header('secret', '{}')
    expect(last_response.status).to eq(404)
  end
end
