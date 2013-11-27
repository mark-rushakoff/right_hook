require 'spec_helper'

describe RightHook::Subscriber do
  subject(:subscriber) do
    described_class.new(
      oauth_token: 'my_token',
      owner: 'mark-rushakoff',
      base_url: 'http://example.com',
      event_type: RightHook::Event::ISSUE,
      user_agent: 'My-User-Agent',
    )
  end

  describe '.subscribe' do
    let!(:stubbed_request) do
      stub_request(:post, 'https://api.github.com/hub').
        with(:body => 'hub.mode=subscribe&hub.topic=https%3A%2F%2Fgithub.com%2Fmark-rushakoff%2Fright_hook%2Fevents%2Fissues&hub.callback=http%3A%2F%2Fexample.com%2Fhook%2Fmark-rushakoff%2Fright_hook%2Fissue&hub.secret=the-secret',
             :headers => {'Authorization' => 'token my_token', 'User-Agent' => 'My-User-Agent'}
            ).to_return(:status => status_code, :body => '', :headers => {})
    end

    context 'When the request succeeds' do
      let(:status_code) { 200 }
      it 'does not raise' do
        expect {
          subscriber.subscribe(repo_name: 'right_hook', secret: 'the-secret')
        }.not_to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When the request fails' do
      let(:status_code) { 404 }
      it 'raises' do
        expect {
          subscriber.subscribe(repo_name: 'right_hook', secret: 'the-secret')
        }.to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When everything is overridden' do
      let(:status_code) { 200 }
      it 'works' do
        expect {
          described_class.new.subscribe(
            repo_name: 'right_hook',
            secret: 'the-secret',
            oauth_token: 'my_token',
            owner: 'mark-rushakoff',
            base_url: 'http://example.com',
            event_type: RightHook::Event::ISSUE,
            user_agent: 'My-User-Agent',
          )
        }.not_to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end
  end

  describe '.subscribe_direct' do
    let!(:stubbed_request) do
      stub_request(:post, 'https://api.github.com/hub').
        with(:body => 'hub.mode=subscribe&hub.topic=https%3A%2F%2Fgithub.com%2Fmark-rushakoff%2Fright_hook%2Fevents%2Fissues&hub.callback=http%3A%2F%2Fhook.example.com&hub.secret=the-secret',
             :headers => {'Authorization' => 'token my_token', 'User-Agent' => 'My-User-Agent'}
            ).to_return(:status => status_code, :body => '', :headers => {})
    end

    context 'When the request succeeds' do
      let(:status_code) { 200 }
      it 'does not raise' do
        expect {
          subscriber.subscribe_direct(repo_name: 'right_hook', secret: 'the-secret', url: 'http://hook.example.com')
        }.not_to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When the request fails' do
      let(:status_code) { 404 }
      it 'raises' do
        expect {
          subscriber.subscribe_direct(repo_name: 'right_hook', secret: 'the-secret', url: 'http://hook.example.com')
        }.to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When everything is overridden' do
      let(:status_code) { 200 }
      it 'works' do
        expect {
          described_class.new.subscribe_direct(
            owner: 'mark-rushakoff',
            repo_name: 'right_hook',
            event_type: RightHook::Event::ISSUE,
            url: 'http://hook.example.com',
            secret: 'the-secret',
            oauth_token: 'my_token',
            user_agent: 'My-User-Agent',
          )
        }.not_to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end
  end

  describe '.unsubscribe' do
    let!(:stubbed_request) do
      stub_request(:post, 'https://api.github.com/hub').
        with(:body => 'hub.mode=unsubscribe&hub.topic=https%3A%2F%2Fgithub.com%2Fmark-rushakoff%2Fright_hook%2Fevents%2Fissues&hub.callback=http%3A%2F%2Fexample.com%2Fhook%2Fmark-rushakoff%2Fright_hook%2Fissue&hub.secret=the-secret',
             :headers => {'Authorization' => 'token my_token', 'User-Agent' => 'My-User-Agent'}
            ).to_return(:status => status_code, :body => '', :headers => {})
    end


    context 'When the request succeeds' do
      let(:status_code) { 200 }
      it 'does not raise' do
        expect {
          subscriber.unsubscribe(repo_name: 'right_hook', secret: 'the-secret')
        }.not_to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When the request fails' do
      let(:status_code) { 404 }
      it 'raises' do
        expect {
          subscriber.unsubscribe(repo_name: 'right_hook', secret: 'the-secret')
        }.to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end
  end

  describe '.unsubscribe_direct' do
    let!(:stubbed_request) do
      stub_request(:post, 'https://api.github.com/hub').
        with(:body => 'hub.mode=unsubscribe&hub.topic=https%3A%2F%2Fgithub.com%2Fmark-rushakoff%2Fright_hook%2Fevents%2Fissues&hub.callback=http%3A%2F%2Fhook.example.com&hub.secret=the-secret',
             :headers => {'Authorization' => 'token my_token', 'User-Agent' => 'My-User-Agent'}
            ).to_return(:status => status_code, :body => '', :headers => {})
    end

    context 'When the request succeeds' do
      let(:status_code) { 200 }
      it 'does not raise' do
        expect {
          subscriber.unsubscribe_direct(repo_name: 'right_hook', secret: 'the-secret', url: 'http://hook.example.com')
        }.not_to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When the request fails' do
      let(:status_code) { 404 }
      it 'raises' do
        expect {
          subscriber.unsubscribe_direct(repo_name: 'right_hook', secret: 'the-secret', url: 'http://hook.example.com')
        }.to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end

    context 'When everything is overridden' do
      let(:status_code) { 200 }
      it 'works' do
        expect {
          described_class.new.unsubscribe_direct(
            owner: 'mark-rushakoff',
            repo_name: 'right_hook',
            event_type: RightHook::Event::ISSUE,
            url: 'http://hook.example.com',
            secret: 'the-secret',
            oauth_token: 'my_token',
            user_agent: 'My-User-Agent',
          )
        }.not_to raise_error

        expect(stubbed_request).to have_been_requested
      end
    end
  end
end
