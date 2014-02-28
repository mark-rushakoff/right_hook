require 'spec_helper'

describe RightHook::App do
  describe 'Issue Comments' do
    class IssueCommentApp < RightHook::App
      class << self
        attr_accessor :owner, :repo_name, :issue_json, :comment_json
      end

      def on_issue_comment(owner, repo_name, issue_json, comment_json)
        self.class.owner = owner
        self.class.repo_name = repo_name
        self.class.issue_json = issue_json
        self.class.comment_json = comment_json
      end

      def secret(owner, repo_name, event_type)
        'issue_comment' if owner == 'mark-rushakoff' && repo_name == 'right_hook' && event_type == 'issue_comment'
      end
    end

    def app
      IssueCommentApp
    end

    before do
      app.owner = app.repo_name = app.issue_json = app.comment_json = nil
    end

    it 'captures the interesting data' do
      post_with_signature(path: '/hook/mark-rushakoff/right_hook/issue_comment', payload: ISSUE_COMMENT_JSON, secret: 'issue_comment')
      expect(last_response.status).to eq(200)
      expect(app.owner).to eq('mark-rushakoff')
      expect(app.repo_name).to eq('right_hook')

      # if it has one key it probably has them all
      expect(app.issue_json['title']).to eq('Found a bug')
      expect(app.comment_json['body']).to eq('Me too')
    end

    it 'fails when the secret is wrong' do
      post_with_signature(path: '/hook/mark-rushakoff/right_hook/issue_comment', payload: ISSUE_COMMENT_JSON, secret: 'wrong')
      expect(last_response.status).to eq(202)
      expect(app.owner).to be_nil
    end
  end
end

# from http://developer.github.com/v3/issues/#get-a-single-issue
ISSUE_COMMENT_JSON = <<-JSON
{
  "action": "created",
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
  },
  "comment": {
    "id": 1,
    "url": "https://api.github.com/repos/octocat/Hello-World/issues/comments/1",
    "html_url": "https://github.com/octocat/Hello-World/issues/1347#issuecomment-1",
    "body": "Me too",
    "user": {
      "login": "octocat",
      "id": 1,
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "somehexcode",
      "url": "https://api.github.com/users/octocat",
      "html_url": "https://github.com/octocat",
      "followers_url": "https://api.github.com/users/octocat/followers",
      "following_url": "https://api.github.com/users/octocat/following{/other_user}",
      "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
      "organizations_url": "https://api.github.com/users/octocat/orgs",
      "repos_url": "https://api.github.com/users/octocat/repos",
      "events_url": "https://api.github.com/users/octocat/events{/privacy}",
      "received_events_url": "https://api.github.com/users/octocat/received_events",
      "type": "User",
      "site_admin": false
    },
    "created_at": "2011-04-14T16:00:49Z",
    "updated_at": "2011-04-14T16:00:49Z"
  }
}
JSON
