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

  describe 'when an app implements the hook method' do
    class WeirdApp < BareApp
      def on_issue(owner, repo_name, action, issue_json)
        302
      end
    end

    let(:app) { WeirdApp }

    let(:payload) { '{}' }

    it 'responds with a 200 regardless of what the hook method returns' do
      expect_any_instance_of(WeirdApp).to receive(:on_issue).and_call_original

      post_with_signature(path: '/hook/mark-rushakoff/right_hook/issue', payload: payload, secret: 'secret')
      expect(last_response.status).to eq(200)
    end

    it 'does not call the hook method when a ping event is received' do
      expect_any_instance_of(WeirdApp).not_to receive(:on_issue)

      post(
        '/hook/mark-rushakoff/right_hook/issue',
        {payload: payload},
        generate_secret_header('secret', URI.encode_www_form(payload: payload)).merge(
          'HTTP_X_GITHUB_EVENT' => 'ping'
        ),
      )
    end
  end
end
