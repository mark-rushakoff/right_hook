require 'spec_helper'

describe RightHook::Event do
  describe '.github_name' do
    it 'maps all known types' do
      described_class::KNOWN_TYPES.each do |type|
        expect {
          described_class.github_name(type)
        }.not_to raise_error
      end
    end
  end
end
