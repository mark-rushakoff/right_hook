require 'spec_helper'
require 'rack/test'

describe RightHook::App do
  describe 'Issues' do
    include Rack::Test::Methods

    class IssueApp < RightHook::App
      class << self
        attr_accessor :owner, :repo_name, :action, :issue_json
      end

      def on_issue(owner, repo_name, action, issue_json)
        self.class.owner = owner
        self.class.repo_name = repo_name
        self.class.action = action
        self.class.issue_json = issue_json
      end

      def secret(owner, repo_name, event_type)
        'issue' if owner == 'mark-rushakoff' && repo_name == 'right_hook' && event_type == 'issue'
      end
    end

    def app
      IssueApp
    end

    before do
      app.owner = app.repo_name = app.action = app.issue_json = nil
    end

    it 'captures the interesting data' do
      post '/hook/mark-rushakoff/right_hook/issue', ISSUE_JSON, generate_secret_header('issue', ISSUE_JSON)
      expect(last_response.status).to eq(200)
      expect(app.owner).to eq('mark-rushakoff')
      expect(app.repo_name).to eq('right_hook')
      expect(app.action).to eq('opened')

      # if it has one key it probably has them all
      expect(app.issue_json['title']).to eq('Found a bug')
    end

    it 'fails when the secret is wrong' do
      post '/hook/mark-rushakoff/right_hook/issue', ISSUE_JSON, generate_secret_header('wrong', ISSUE_JSON)
      expect(last_response.status).to eq(202)
      expect(app.owner).to be_nil
    end
  end
end

# from http://developer.github.com/v3/issues/#get-a-single-issue
ISSUE_JSON = <<-JSON
{
  "action": "opened",
  "issue": {
    "url": "https://api.github.com/repos/octocat/Hello-World/issues/1347",
    "html_url": "https://github.com/octocat/Hello-World/issues/1347",
    "number": 1347,
    "state": "open",
    "title": "Found a bug",
    "body": "I'm having a problem with this.",
    "user": {
      "login": "octocat",
      "id": 1,
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "somehexcode",
      "url": "https://api.github.com/users/octocat"
    },
    "labels": [
      {
        "url": "https://api.github.com/repos/octocat/Hello-World/labels/bug",
        "name": "bug",
        "color": "f29513"
      }
    ],
    "assignee": {
      "login": "octocat",
      "id": 1,
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "somehexcode",
      "url": "https://api.github.com/users/octocat"
    },
    "milestone": {
      "url": "https://api.github.com/repos/octocat/Hello-World/milestones/1",
      "number": 1,
      "state": "open",
      "title": "v1.0",
      "description": "",
      "creator": {
        "login": "octocat",
        "id": 1,
        "avatar_url": "https://github.com/images/error/octocat_happy.gif",
        "gravatar_id": "somehexcode",
        "url": "https://api.github.com/users/octocat"
      },
      "open_issues": 4,
      "closed_issues": 8,
      "created_at": "2011-04-10T20:09:31Z",
      "due_on": null
    },
    "comments": 0,
    "pull_request": {
      "html_url": "https://github.com/octocat/Hello-World/pull/1347",
      "diff_url": "https://github.com/octocat/Hello-World/pull/1347.diff",
      "patch_url": "https://github.com/octocat/Hello-World/pull/1347.patch"
    },
    "closed_at": null,
    "created_at": "2011-04-22T13:33:48Z",
    "updated_at": "2011-04-22T13:33:48Z"
  }
}
JSON
