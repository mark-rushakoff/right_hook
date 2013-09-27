require 'sinatra/base'
require 'json'

module CaptainHook
  class App < Sinatra::Base
    post '/github_hook' do
      json = JSON.parse(request.body.read)

      on_pull_request(json["action"], json["number"], json["pull_request"])
    end
  end
end
