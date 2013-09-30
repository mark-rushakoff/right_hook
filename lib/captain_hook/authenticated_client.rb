require 'octokit'

module CaptainHook
  # A base class for CaptainHook actors that interact with the GitHub API.
  class AuthenticatedClient
    # Create a new client, authenticating with the given OAuth token.
    def initialize(token)
      @client = Octokit::Client.new(access_token: token)
    end

    private
    attr_reader :client
  end
end
