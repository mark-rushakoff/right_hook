require 'right_hook/authenticated_client'
require 'octokit'

module RightHook
  # Provides an interface for adding comments on GitHub
  class Commenter < AuthenticatedClient
    def comment_on_issue(owner, repo_name, issue_number, comment)
      client.add_comment("#{owner}/#{repo_name}", issue_number, comment)
    end
  end
end
