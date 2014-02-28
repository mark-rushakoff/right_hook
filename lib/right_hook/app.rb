require 'sinatra/base'
require 'json'

require 'right_hook/event'

module RightHook
  # Inherit from this class and implement the on_issue, on_pull_request, etc. methods to
  # configure how you respond to GitHub hooks.
  class App < Sinatra::Base
    post '/hook/:owner/:repo_name/:event_type' do
      owner = params[:owner]
      repo_name = params[:repo_name]
      event_type = params[:event_type]
      content = request.body.read

      halt 404, "Unknown event type" unless Event::KNOWN_TYPES.include?(event_type)
      halt 501, "Event type not implemented" unless respond_to?("on_#{event_type}")

      require_valid_signature(content, owner, repo_name, event_type)

      json = JSON.parse(params['payload'])
      case event_type
      when Event::PULL_REQUEST
        on_pull_request(owner, repo_name, json['action'], json['pull_request'])
      when Event::ISSUE
        on_issue(owner, repo_name, json['action'], json['issue'])
      when Event::ISSUE_COMMENT
        on_issue_comment(owner, repo_name, json['issue'], json['comment'])
      else
        halt 500, "Server bug"
      end

      200
    end

    # It is up to you to override secret to determine how to look up the correct secret for an owner/repo combo.
    def secret(owner, repo_name, event_type)
      raise NotImplementedError, "You didn't specify how to find the secret for a repo!"
    end

    private
    def require_valid_signature(content, owner, repo_name, event_type)
      s = secret(owner, repo_name, event_type)
      expected_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), s, content)

      # http://pubsubhubbub.googlecode.com/git/pubsubhubbub-core-0.4.html#authednotify
      # "If the signature does not match, subscribers MUST still return a 2xx success response to acknowledge receipt, but locally ignore the message as invalid."
      received_signature = request.env['HTTP_X_HUB_SIGNATURE']
      calculated_signature = "sha1=#{expected_signature}"
      halt 202, "Signature mismatch" unless received_signature == calculated_signature
    end
  end

  # Use this class if you're getting a mysterious 500 error in a test and you want to see what went wrong.
  # Don't use it in production.
  class DebugApp < App
    disable :show_exceptions
    disable :dump_errors
    enable :raise_errors
  end
end
