require 'spec_helper'
require 'rack/test'

describe CaptainHook::App do
  describe 'Pull requests' do
    include Rack::Test::Methods

    class PullRequestApp < CaptainHook::App
      class << self
        attr_accessor :owner, :repo_name, :action, :number, :pull_request_json
      end

      def on_pull_request(owner, repo_name, action, number, pull_request_json)
        self.class.owner = owner
        self.class.repo_name = repo_name
        self.class.action = action
        self.class.number = number
        self.class.pull_request_json = pull_request_json
      end
    end

    def app
      PullRequestApp
    end

    it 'captures the interesting data' do
      post '/hook/mark-rushakoff/captain_hook/pull_request', PULL_REQUEST_JSON
      expect(app.owner).to eq('mark-rushakoff')
      expect(app.repo_name).to eq('captain_hook')
      expect(app.action).to eq('opened')
      expect(app.number).to eq(1)

      # if it has one key it probably has them all
      expect(app.pull_request_json['body']).to eq('Please pull these awesome changes')
    end
  end
end

# from http://developer.github.com/v3/pulls/#get-a-single-pull-request
PULL_REQUEST_JSON = <<-JSON
{
  "action": "opened",
  "number": 1,
  "pull_request": {
    "url": "https://api.github.com/octocat/Hello-World/pulls/1",
    "html_url": "https://github.com/octocat/Hello-World/pull/1",
    "diff_url": "https://github.com/octocat/Hello-World/pulls/1.diff",
    "patch_url": "https://github.com/octocat/Hello-World/pulls/1.patch",
    "issue_url": "https://github.com/octocat/Hello-World/issue/1",
    "number": 1,
    "state": "open",
    "title": "new-feature",
    "body": "Please pull these awesome changes",
    "created_at": "2011-01-26T19:01:12Z",
    "updated_at": "2011-01-26T19:01:12Z",
    "closed_at": "2011-01-26T19:01:12Z",
    "merged_at": "2011-01-26T19:01:12Z",
    "head": {
      "label": "new-topic",
      "ref": "new-topic",
      "sha": "6dcb09b5b57875f334f61aebed695e2e4193db5e",
      "user": {
        "login": "octocat",
        "id": 1,
        "avatar_url": "https://github.com/images/error/octocat_happy.gif",
        "gravatar_id": "somehexcode",
        "url": "https://api.github.com/users/octocat"
      },
      "repo": {
        "id": 1296269,
        "owner": {
          "login": "octocat",
          "id": 1,
          "avatar_url": "https://github.com/images/error/octocat_happy.gif",
          "gravatar_id": "somehexcode",
          "url": "https://api.github.com/users/octocat"
        },
        "name": "Hello-World",
        "full_name": "octocat/Hello-World",
        "description": "This your first repo!",
        "private": false,
        "fork": false,
        "url": "https://api.github.com/repos/octocat/Hello-World",
        "html_url": "https://github.com/octocat/Hello-World",
        "clone_url": "https://github.com/octocat/Hello-World.git",
        "git_url": "git://github.com/octocat/Hello-World.git",
        "ssh_url": "git@github.com:octocat/Hello-World.git",
        "svn_url": "https://svn.github.com/octocat/Hello-World",
        "mirror_url": "git://git.example.com/octocat/Hello-World",
        "homepage": "https://github.com",
        "language": null,
        "forks": 9,
        "forks_count": 9,
        "watchers": 80,
        "watchers_count": 80,
        "size": 108,
        "master_branch": "master",
        "open_issues": 0,
        "open_issues_count": 0,
        "pushed_at": "2011-01-26T19:06:43Z",
        "created_at": "2011-01-26T19:01:12Z",
        "updated_at": "2011-01-26T19:14:43Z"
      }
    },
    "base": {
      "label": "master",
      "ref": "master",
      "sha": "6dcb09b5b57875f334f61aebed695e2e4193db5e",
      "user": {
        "login": "octocat",
        "id": 1,
        "avatar_url": "https://github.com/images/error/octocat_happy.gif",
        "gravatar_id": "somehexcode",
        "url": "https://api.github.com/users/octocat"
      },
      "repo": {
        "id": 1296269,
        "owner": {
          "login": "octocat",
          "id": 1,
          "avatar_url": "https://github.com/images/error/octocat_happy.gif",
          "gravatar_id": "somehexcode",
          "url": "https://api.github.com/users/octocat"
        },
        "name": "Hello-World",
        "full_name": "octocat/Hello-World",
        "description": "This your first repo!",
        "private": false,
        "fork": false,
        "url": "https://api.github.com/repos/octocat/Hello-World",
        "html_url": "https://github.com/octocat/Hello-World",
        "clone_url": "https://github.com/octocat/Hello-World.git",
        "git_url": "git://github.com/octocat/Hello-World.git",
        "ssh_url": "git@github.com:octocat/Hello-World.git",
        "svn_url": "https://svn.github.com/octocat/Hello-World",
        "mirror_url": "git://git.example.com/octocat/Hello-World",
        "homepage": "https://github.com",
        "language": null,
        "forks": 9,
        "forks_count": 9,
        "watchers": 80,
        "watchers_count": 80,
        "size": 108,
        "master_branch": "master",
        "open_issues": 0,
        "open_issues_count": 0,
        "pushed_at": "2011-01-26T19:06:43Z",
        "created_at": "2011-01-26T19:01:12Z",
        "updated_at": "2011-01-26T19:14:43Z"
      }
    },
    "_links": {
      "self": {
        "href": "https://api.github.com/octocat/Hello-World/pulls/1"
      },
      "html": {
        "href": "https://github.com/octocat/Hello-World/pull/1"
      },
      "comments": {
        "href": "https://api.github.com/octocat/Hello-World/issues/1/comments"
      },
      "review_comments": {
        "href": "https://api.github.com/octocat/Hello-World/pulls/1/comments"
      }
    },
    "user": {
      "login": "octocat",
      "id": 1,
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "somehexcode",
      "url": "https://api.github.com/users/octocat"
    },
    "merge_commit_sha": "e5bd3914e2e596debea16f433f57875b5b90bcd6",
    "merged": false,
    "mergeable": true,
    "merged_by": {
      "login": "octocat",
      "id": 1,
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "somehexcode",
      "url": "https://api.github.com/users/octocat"
    },
    "comments": 10,
    "commits": 3,
    "additions": 100,
    "deletions": 3,
    "changed_files": 5
  }
}
JSON
