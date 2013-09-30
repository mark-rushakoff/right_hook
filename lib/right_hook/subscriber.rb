require 'httparty'
require 'right_hook/event'
require 'right_hook/logger'

module RightHook
  # Subscriber can subscribe and unsubscribe GitHub hooks to a hosted instance of a specified {RightHook::App}.
  # See the README for sample usage.
  class Subscriber
    # The base URL for the binding (where your {RightHook::App} is hosted).
    attr_accessor :base_url

    # The OAuth token to use for authenticating with GitHub.
    # The token must belong to an account that has the +repo+ scope and collaborator privilege on the given repository.
    attr_accessor :oauth_token

    # The owner of the named repository.
    attr_accessor :owner

    # The event type of the hook.
    # See http://developer.github.com/v3/repos/hooks/ for a complete list of valid types.
    attr_accessor :event_type

    # Initialize takes options which will be used as default values in other methods.
    # The valid keys in the options are [+base_url+, +oauth_token+, +owner+, and +event_type+].
    def initialize(default_opts = {})
      @base_url = default_opts[:base_url]
      @oauth_token = default_opts[:oauth_token]
      @owner = default_opts[:owner]
      @event_type = default_opts[:event_type]
    end

    # Subscribe an instance of {RightHook::App} hosted at +base_url+ to a hook for +owner+/+repo_name+, authenticating with +oauth_token+.
    # +repo_name+ and +secret+ are required options and they are intentionally not stored as defaults on the +Subscriber+ instance.
    # @return [bool success] Whether the request was successful.
    def subscribe(opts)
      hub_request_with_mode('subscribe', opts)
    end

    # Unsubscribe an instance of {RightHook::App} hosted at +base_url+ to a hook for +owner+/+repo_name+, authenticating with +oauth_token+.
    # +repo_name+ and +secret+ are required options and they are intentionally not stored as defaults on the +Subscriber+ instance.
    # (NB: It's possible that GitHub's API *doesn't* require secret; I haven't checked.)
    # @return [bool success] Whether the request was successful.
    def unsubscribe(opts)
      hub_request_with_mode('unsubscribe', opts)
    end

    private
    def hub_request_with_mode(mode, opts)
      repo_name = opts.fetch(:repo_name) # explicitly not defaulted
      secret = opts.fetch(:secret) # explicitly not defaulted
      oauth_token = opts.fetch(:oauth_token) { self.oauth_token }
      owner = opts.fetch(:owner) { self.owner }
      base_url = opts.fetch(:base_url) { self.base_url }
      event_type = opts.fetch(:event_type) { self.event_type }

      response = HTTParty.post('https://api.github.com/hub',
        headers: {
          # http://developer.github.com/v3/#authentication
          'Authorization' => "token #{oauth_token}"
        },
        body: {
          'hub.mode' => mode,
          'hub.topic' => "https://github.com/#{owner}/#{repo_name}/events/#{Event.github_name(event_type)}",
          'hub.callback' => "#{base_url}/hook/#{owner}/#{repo_name}/#{event_type}",
          'hub.secret' => secret
        }
      )

      RightHook.logger.warn("Failure modifying subscription: #{response.inspect}") unless response.success?

      response.success?
    end
  end
end
