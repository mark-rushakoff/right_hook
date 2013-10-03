require 'httparty'
require 'right_hook/event'
require 'right_hook/logger'

module RightHook
  # Subscriber can subscribe and unsubscribe GitHub hooks to a hosted instance of a specified {RightHook::App}.
  # See the README for sample usage.
  class Subscriber
    # The base URL for the binding (where your {RightHook::App} is hosted).
    attr_accessor :base_url
    #
    # The full target URL for the binding when used with #subscribe_direct.
    attr_accessor :url

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
    # @param [Hash] opts Subscription options. Defaults to attr_reader methods when such methods exist.
    # @option opts [String] :owner The owner of the repository
    # @option opts [String] :event_type A constant under RightHook::Event representing an event type
    # @option opts [String] :base_url The URL of where the {RightHook::App} is hosted
    # @option opts [String] :url The URL to receive requests from GitHub when a hook is activated
    # @option opts [String] :oauth_token The OAuth token to use to authenticate with GitHub when subscribing
    def initialize(default_opts = {})
      @base_url = default_opts[:base_url]
      @url = default_opts[:url]
      @oauth_token = default_opts[:oauth_token]
      @owner = default_opts[:owner]
      @event_type = default_opts[:event_type]
    end

    # Subscribe an instance of {RightHook::App} hosted at +base_url+ to a hook for +owner+/+repo_name+, authenticating with +oauth_token+.
    # +repo_name+ and +secret+ are required options and they are intentionally not stored as defaults on the +Subscriber+ instance.
    # @param [Hash] opts Subscription options. Defaults to attr_reader methods when such methods exist.
    # @return [bool success] Whether the request was successful.
    # @option opts [String] :owner The owner of the repository
    # @option opts [String] :repo_name The name of the repository
    # @option opts [String] :event_type A constant under RightHook::Event representing an event type
    # @option opts [String] :base_url The URL of where the {RightHook::App} is hosted
    # @option opts [String] :secret The secret to use to validate that a request came from GitHub. May be omitted
    # @option opts [String] :oauth_token The OAuth token to use to authenticate with GitHub when subscribing
    def subscribe(opts)
      hub_request_with_mode('subscribe', opts)
    end

    # Unsubscribe an instance of {RightHook::App} hosted at +base_url+ to a hook for +owner+/+repo_name+, authenticating with +oauth_token+.
    # +repo_name+ and +secret+ are required options and they are intentionally not stored as defaults on the +Subscriber+ instance.
    # (NB: It's possible that GitHub's API *doesn't* require secret; I haven't checked.)
    # @param [Hash] opts Subscription options. Defaults to attr_reader methods when such methods exist.
    # @return [bool success] Whether the request was successful.
    # @option opts [String] :owner The owner of the repository
    # @option opts [String] :repo_name The name of the repository
    # @option opts [String] :event_type A constant under RightHook::Event representing an event type
    # @option opts [String] :base_url The URL of where the {RightHook::App} is hosted
    # @option opts [String] :secret The secret to use to validate that a request came from GitHub. May be omitted
    # @option opts [String] :oauth_token The OAuth token to use to authenticate with GitHub when subscribing
    def unsubscribe(opts)
      hub_request_with_mode('unsubscribe', opts)
    end

    # Subscribe directly to a fixed URL, rather than a calculated URL for an instance of {RightHook::App}.
    # @return [bool success] Whether the request was successful.
    # @param [Hash] opts Subscription options. Defaults to attr_reader methods when such methods exist.
    # @option opts [String] :owner The owner of the repository
    # @option opts [String] :repo_name The name of the repository
    # @option opts [String] :event_type A constant under RightHook::Event representing an event type
    # @option opts [String] :url The URL to receive requests from GitHub when a hook is activated
    # @option opts [String] :secret The secret to use to validate that a request came from GitHub. May be omitted
    # @option opts [String] :oauth_token The OAuth token to use to authenticate with GitHub when subscribing
    def subscribe_direct(opts)
      direct_hub_request_with_mode('subscribe', opts)
    end

    # Unsubscribe directly to a fixed URL, rather than a calculated URL for an instance of {RightHook::App}.
    # @return [bool success] Whether the request was successful.
    # @param [Hash] opts Subscription options. Defaults to attr_reader methods when such methods exist.
    # @option opts [String] :owner The owner of the repository
    # @option opts [String] :repo_name The name of the repository
    # @option opts [String] :event_type A constant under RightHook::Event representing an event type
    # @option opts [String] :url The URL to receive requests from GitHub when a hook is activated
    # @option opts [String] :secret The secret to use to validate that a request came from GitHub. May be omitted
    # @option opts [String] :oauth_token The OAuth token to use to authenticate with GitHub when subscribing
    def unsubscribe_direct(opts)
      direct_hub_request_with_mode('unsubscribe', opts)
    end

    private
    def hub_request_with_mode(mode, opts)
      repo_name = opts.fetch(:repo_name) # explicitly not defaulted
      owner = opts.fetch(:owner) { self.owner }
      base_url = opts.fetch(:base_url) { self.base_url }
      event_type = opts.fetch(:event_type) { self.event_type }

      url = "#{base_url}/hook/#{owner}/#{repo_name}/#{event_type}"
      direct_hub_request_with_mode(mode, opts.merge(url: url))
    end

    def direct_hub_request_with_mode(mode, opts)
      repo_name = opts.fetch(:repo_name) # explicitly not defaulted
      url = opts.fetch(:url) # explicitly not defaulted
      secret = opts.fetch(:secret, nil)
      owner = opts.fetch(:owner) { self.owner }
      oauth_token = opts.fetch(:oauth_token) { self.oauth_token }
      event_type = opts.fetch(:event_type) { self.event_type }

      response = HTTParty.post('https://api.github.com/hub',
        headers: {
          # http://developer.github.com/v3/#authentication
          'Authorization' => "token #{oauth_token}"
        },
        body: {
        'hub.mode' => mode,
        'hub.topic' => "https://github.com/#{owner}/#{repo_name}/events/#{Event.github_name(event_type)}",
        'hub.callback' => url,
        'hub.secret' => secret,
        },
      )

      raise "Failure modifying direct subscription: #{response.inspect}" unless response.success?
    end
  end
end
