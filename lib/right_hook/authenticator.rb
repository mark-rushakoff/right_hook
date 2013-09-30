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
      _client.create_authorization(scopes: %w(repo), note: note).token
    end

    # Returns an array of all of the authorizations for the authenticated account.
    def list_authorizations
      _client.authorizations
    end

    # If there is already an authorization by this note, use it; otherwise create it
    def find_or_create_authorization_by_note(note)
      found_auth = list_authorizations.find {|auth| auth.note == note}
      if found_auth
        found_auth.token
      else
        create_authorization(note)
      end
    end

    private
    attr_reader :_client
    # Enforce use of build methods
    private_class_method :new
  end
end
