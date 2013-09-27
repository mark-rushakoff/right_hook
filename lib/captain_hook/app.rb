require 'sinatra/base'
require 'json'

module CaptainHook
  class App < Sinatra::Base
    post '/hook/:owner/:repo_name/pull_request' do
      json = JSON.parse(request.body.read)

      on_pull_request(params[:owner], params[:repo_name], json['action'], json['number'], json['pull_request'])
    end

    post '/hook/:owner/:repo_name/issue' do
      json = JSON.parse(request.body.read)

      on_issue(params[:owner], params[:repo_name], json['action'], json['issue'])
    end
  end
end
