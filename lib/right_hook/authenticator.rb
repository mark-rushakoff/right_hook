require 'octokit'

module RightHook
  # The authenticator provides an interface to retrieving or creating GitHub authorizations.
  class Authenticator
    class << self
      # Build a client with a username and an explicit password.
      def build(username, password)
        new(Octokit::Client.new(login: username, password: password))
      end

      # Prompt the user for their password (without displaying the entered keys).
      # This approach is offered for convenience to make it easier to not store passwords on disk.
      def interactive_build(username)
        require 'io/console'
        new(Octokit::Client.new(login: username, password: $stdin.noecho(&:gets).chomp))
      end
    end

    # :nodoc:
    def initialize(_client)
      @_client = _client
    end

    # Create a new GitHub authorization with the given note.
    # If one already exists with that note, it will not create a duplicate.
    def create_authorization(note)
      _client.create_authorization(scopes: %w(repo), note: note, idempotent: true).token
    end

    # Returns an array of all of the authorizations for the authenticated account.
    def list_authorizations
      _client.list_authorizations
    end

    private
    attr_reader :_client
    # Enforce use of build methods
    private_class_method :new
  end
end