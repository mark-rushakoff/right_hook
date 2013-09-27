require 'sinatra/base'
require 'json'

module CaptainHook
  class App < Sinatra::Base
    post '/hook/pull_request' do
      json = JSON.parse(request.body.read)

      on_pull_request(json['action'], json['number'], json['pull_request'])
    end

    post '/hook/issue' do
      json = JSON.parse(request.body.read)

      on_issue(json['action'], json['issue'])
    end
  end
end
