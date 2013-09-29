require 'sinatra/base'
require 'json'

module CaptainHook
  class App < Sinatra::Base
    KNOWN_EVENT_TYPES = %w(
      pull_request
      issue
    )

    post '/hook/:owner/:repo_name/:event_type' do
      owner = params[:owner]
      repo_name = params[:repo_name]
      event_type = params[:event_type]
      content = request.body.read

      halt 404 unless KNOWN_EVENT_TYPES.include?(event_type)
      halt 501 unless respond_to?("on_#{event_type}")

      require_valid_signature(content, owner, repo_name, event_type)

      json = JSON.parse(content)
      case event_type
      when 'pull_request'
        on_pull_request(owner, repo_name, json['action'], json['number'], json['pull_request'])
      when 'issue'
        on_issue(owner, repo_name, json['action'], json['issue'])
      else
        halt 500
      end
    end

    def require_valid_signature(content, owner, repo_name, event_type)
      s = secret(owner, repo_name, event_type)
      expected_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), s, content)

      # http://pubsubhubbub.googlecode.com/git/pubsubhubbub-core-0.4.html#authednotify
      # "If the signature does not match, subscribers MUST still return a 2xx success response to acknowledge receipt, but locally ignore the message as invalid."
      halt 202 unless request.env['X-Hub-Signature'] == "sha1=#{expected_signature}"
    end
  end
end
