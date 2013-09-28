require 'httparty'

module CaptainHook
  class Subscriber
    attr_reader :base_url, :oauth_token

    def initialize(base_url, oauth_token)
      @base_url = base_url
      @oauth_token = oauth_token
    end

    def subscribe!(owner, repo_name, event_type, secret)
      hub_request_with_mode('subscribe', owner, repo_name, event_type, secret)
    end

    def unsubscribe!(owner, repo_name, event_type, secret)
      hub_request_with_mode('unsubscribe', owner, repo_name, event_type, secret)
    end

    private
    def hub_request_with_mode(mode, owner, repo_name, event_type, secret)
      HTTParty.post('https://api.github.com/hub',
        headers: {
          # http://developer.github.com/v3/#authentication
          'Authorization' => "token #{oauth_token}"
        },
        body: {
          'hub.mode' => mode,
          'hub.topic' => "https://github.com/#{owner}/#{repo_name}/events/#{event_type}",
          'hub.callback' => "#{base_url}/hook/#{owner}/#{repo_name}/#{event_type}",
          'hub.secret' => secret
        }
      ).success?
    end
  end
end
