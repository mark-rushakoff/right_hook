require 'spec_helper'
require 'octokit'

describe RightHook::Authenticator do
  describe '.build' do
    it 'delegates to Octokit' do
      Octokit::Client.should_receive(:new).with(login: 'octocat', password: 'pass')

      described_class.build('octocat', 'pass')
    end
  end

  describe '.interactive_build' do
    it 'delegates to Octokit and stdin.noecho' do
      $stdin.should_receive(:noecho).and_return("pass\n")
      Octokit::Client.should_receive(:new).with(login: 'octocat', password: 'pass')

      described_class.interactive_build('octocat')
    end
  end

  describe '#create_authorization' do
    it 'delegates to create_authorization' do
      Octokit::Client.any_instance.should_receive(:create_authorization).with(scopes: %w(repo), note: 'test note').and_return(OpenStruct.new(token: 'my_token'))

      expect(described_class.build('octocat', 'pass').create_authorization('test note')).to eq('my_token')
    end
  end

  describe '#list_authorizations' do
    it 'delegates to list_authorizations' do
      Octokit::Client.any_instance.should_receive(:authorizations).and_return(:the_authorizations)

      expect(described_class.build('octocat', 'pass').list_authorizations).to eq(:the_authorizations)
    end
  end

  describe '#find_or_create_authorization_by_note' do
    let(:auth) { OpenStruct.new(token: 'a token', note: 'the note')}
    context 'when #list_authorizations has a note that is an exact match' do
      before { Octokit::Client.any_instance.should_receive(:list_authorizations).and_return([auth]) }
      it 'returns that authorization' do
        authenticator = described_class.build('octocat', 'pass')
        expect(authenticator.find_or_create_authorization_by_note('the note')).to eq('a token')
      end
    end

    context 'when #list_authorizations does not have a note that matches' do
      before { Octokit::Client.any_instance.should_receive(:list_authorizations).and_return([]) }
      before { Octokit::Client.any_instance.should_receive(:create_authorization).and_return(auth) }
      it 'creates a new authorization' do
        authenticator = described_class.build('octocat', 'pass')
        expect(authenticator.find_or_create_authorization_by_note('the note')).to eq('a token')
      end
    end
  end
end
