require 'sinatra/base'
require 'json'

module CaptainHook
  class App < Sinatra::Base
    post '/hook/:owner/:repo_name/pull_request' do
      content = request.body.read
      require_valid_signature(content, params[:owner], params[:repo_name], :pull_request)

      json = JSON.parse(content)
      on_pull_request(params[:owner], params[:repo_name], json['action'], json['number'], json['pull_request'])
    end

    post '/hook/:owner/:repo_name/issue' do
      content = request.body.read

      require_valid_signature(content, params[:owner], params[:repo_name], :issue)
      json = JSON.parse(content)

      on_issue(params[:owner], params[:repo_name], json['action'], json['issue'])
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
