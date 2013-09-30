require 'captain_hook/authenticated_client'
require 'octokit'

module CaptainHook
  # Provides an interface for adding comments on GitHub
  class Commenter < AuthenticatedClient
    def comment_on_issue(owner, repo_name, issue_number, comment)
      client.add_comment("#{owner}/#{repo_name}", issue_number, comment)
    end
  end
end
