require 'spec_helper'

describe RightHook::App do
  class BareApp < RightHook::DebugApp
    def secret(owner, repo_name, event_type)
      'secret'
    end
  end

  let(:app) { BareApp }

  context 'An app with no hooks implemented' do
    it 'is status 501 for a non-implemented hook' do
      post_with_signature(path: '/hook/mark-rushakoff/right_hook/issue', payload: '{}', secret: '')
      expect(last_response.status).to eq(501)
    end

    it 'is 404 for an unknown hook' do
      post_with_signature(path: '/hook/mark-rushakoff/right_hook/not_a_real_thing', payload: '{}', secret: '')
      expect(last_response.status).to eq(404)
    end
  end

  it 'raises NotImplementedError for an unimplemented secret' do
    expect { RightHook::App.new!.secret('owner', 'repo', 'issue') }.to raise_error(NotImplementedError)
  end

  describe 'the status of a request' do
    class WeirdApp < BareApp
      def on_issue(owner, repo_name, action, issue_json)
        302
      end
    end

    let(:app) { WeirdApp }

    it 'is 200 regardless of what the hook method returns' do
      payload =  '{}'
      WeirdApp.any_instance.should_receive(:on_issue).and_call_original
      post_with_signature(path: '/hook/mark-rushakoff/right_hook/issue', payload: payload, secret: 'secret')
      expect(last_response.status).to eq(200)
    end
  end
end
