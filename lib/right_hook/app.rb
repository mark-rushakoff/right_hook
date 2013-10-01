require 'sinatra/base'
require 'json'

require 'right_hook/event'
require 'right_hook/logger'

module RightHook
  class App < Sinatra::Base
    post '/hook/:owner/:repo_name/:event_type' do
      owner = params[:owner]
      repo_name = params[:repo_name]
      event_type = params[:event_type]
      content = request.body.read

      halt 404, "Unknown event type" unless Event::KNOWN_TYPES.include?(event_type)
      halt 501, "Event type not implemented" unless respond_to?("on_#{event_type}")

      require_valid_signature(content, owner, repo_name, event_type)

      json = JSON.parse(content)
      case event_type
      when Event::PULL_REQUEST
        on_pull_request(owner, repo_name, json['number'], json['action'], json['pull_request'])
      when Event::ISSUE
        on_issue(owner, repo_name, json['action'], json['issue'])
      else
        halt 500, "Server bug"
      end
    end

    private
    def require_valid_signature(content, owner, repo_name, event_type)
      s = secret(owner, repo_name, event_type)
      expected_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), s, content)

      # http://pubsubhubbub.googlecode.com/git/pubsubhubbub-core-0.4.html#authednotify
      # "If the signature does not match, subscribers MUST still return a 2xx success response to acknowledge receipt, but locally ignore the message as invalid."
      received_signature = request.env['X-Hub-Signature']
      calculated_signature = "sha1=#{expected_signature}"
      unless received_signature == calculated_signature
        RightHook.logger.warn('Signature mismatch')
        RightHook.logger.warn("Received:   #{received_signature}")
        RightHook.logger.warn("Calculated: #{calculated_signature}")
        halt 202, "Signature mismatch"
      end
    end
  end
end
