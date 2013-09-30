require 'spec_helper'
require 'octokit'

describe CaptainHook::Client do
  describe '.build' do
    it 'delegates to Octokit' do
      Octokit::Client.should_receive(:new).with(login: 'octocat', password: 'pass')

      CaptainHook::Client.build('octocat', 'pass')
    end
  end

  describe '.interactive_build' do
    it 'delegates to Octokit and stdin.noecho' do
      $stdin.should_receive(:noecho).and_return("pass\n")
      Octokit::Client.should_receive(:new).with(login: 'octocat', password: 'pass')

      CaptainHook::Client.interactive_build('octocat')
    end
  end

  describe '#create_authorization' do
    it 'delegates to create_authorization' do
      Octokit::Client.any_instance.should_receive(:create_authorization).with(scopes: %w(repo), note: 'test note')

      CaptainHook::Client.build('octocat', 'pass').create_authorization('test note')
    end
  end

  describe '#list_authorizations' do
    it 'delegates to list_authorizations' do
      Octokit::Client.any_instance.should_receive(:list_authorizations).and_return(:the_authorizations)

      expect(CaptainHook::Client.build('octocat', 'pass').list_authorizations).to eq(:the_authorizations)
    end
  end
end
