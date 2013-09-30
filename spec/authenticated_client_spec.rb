require 'spec_helper'

describe RightHook::AuthenticatedClient do
  describe '.new' do
    it 'creates an Octokit client with the given token' do
      Octokit::Client.should_receive(:new).with(access_token: 'the_token')

      described_class.new('the_token')
    end
  end
end
