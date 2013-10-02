require 'spec_helper'

describe RightHook::App do
  class BareApp < RightHook::App
    def secret(owner, repo_name, event_type)
      ''
    end
  end

  def app
    BareApp
  end

  it 'is status 501 for a non-implemented hook' do
    post_with_signature(path: '/hook/mark-rushakoff/right_hook/issue', payload: '{}', secret: '')
    expect(last_response.status).to eq(501)
  end

  it 'is 404 for an unknown hook' do
    post_with_signature(path: '/hook/mark-rushakoff/right_hook/not_a_real_thing', payload: '{}', secret: '')
    expect(last_response.status).to eq(404)
  end

  it 'raises NotImplementedError for an unimplemented secret' do
    expect { RightHook::App.new!.secret('owner', 'repo', 'issue') }.to raise_error(NotImplementedError)
  end
end
