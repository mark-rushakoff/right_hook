require 'spec_helper'

describe CaptainHook::Commenter do
  subject(:commenter) do
    described_class.new('a_token')
  end

  describe '.comment_on_issue' do
    it 'delegates to Octokit' do
      Octokit::Client.any_instance.should_receive(:add_comment).with('octocat/Spoon-Fork', 100, "Wow, 100!")

      commenter.comment_on_issue("octocat", "Spoon-Fork", 100, "Wow, 100!")
    end
  end
end
