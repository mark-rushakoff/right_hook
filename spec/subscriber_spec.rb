require 'spec_helper'

describe RightHook::Subscriber do
  subject(:subscriber) do
    described_class.new(
      oauth_token: 'my_token',
      owner: 'mark-rushakoff',
      base_url: 'http://example.com',
      event_type: RightHook::Event::ISSUE,
    )
  end

  describe '.subscribe' do
    let!(:stubbed_request) do
      stub_request(:post, 'https://api.github.com/hub').
        with(:body => 'hub.mode=subscribe&hub.topic=https%3A%2F%2Fgithub.com%2Fmark-rushakoff%2Fright_hook%2Fevents%2Fissues&hub.callback=http%3A%2F%2Fexample.com%2Fhook%2Fmark-rushakoff%2Fright_hook%2Fissue&hub.secret=the-secret',
             :headers => {'Authorization' => 'token my_token'}
            ).to_return(:status => status_code, :body => '', :headers => {})
    end

    context 'When the request succeeds' do
      let(:status_code) { 200 }
      it 'returns true' do
        result = subscriber.subscribe(repo_name: 'right_hook', secret: 'the-secret')
        expect(result).to eq(true)

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When the request fails' do
      let(:status_code) { 404 }
      it 'returns false' do
        result = subscriber.subscribe(repo_name: 'right_hook', secret: 'the-secret')
        expect(result).to eq(false)

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When everything is overridden' do
      let(:status_code) { 200 }
      it 'works' do
        s = described_class.new
        result = s.subscribe(
          repo_name: 'right_hook',
          secret: 'the-secret',
          oauth_token: 'my_token',
          owner: 'mark-rushakoff',
          base_url: 'http://example.com',
          event_type: RightHook::Event::ISSUE
        )
        expect(result).to eq(true)

        expect(stubbed_request).to have_been_requested
      end
    end
  end

  describe '.unsubscribe' do
    let!(:stubbed_request) do
      stub_request(:post, 'https://api.github.com/hub').
        with(:body => 'hub.mode=unsubscribe&hub.topic=https%3A%2F%2Fgithub.com%2Fmark-rushakoff%2Fright_hook%2Fevents%2Fissues&hub.callback=http%3A%2F%2Fexample.com%2Fhook%2Fmark-rushakoff%2Fright_hook%2Fissue&hub.secret=the-secret',
             :headers => {'Authorization' => 'token my_token'}
            ).to_return(:status => status_code, :body => '', :headers => {})
    end


    context 'When the request succeeds' do
      let(:status_code) { 200 }
      it 'returns true' do
        result = subscriber.unsubscribe(repo_name: 'right_hook', secret: 'the-secret')
        expect(result).to eq(true)

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When the request fails' do
      let(:status_code) { 404 }
      it 'returns false' do
        result = subscriber.unsubscribe(repo_name: 'right_hook', secret: 'the-secret')
        expect(result).to eq(false)

        expect(stubbed_request).to have_been_requested
      end
    end
  end
end
