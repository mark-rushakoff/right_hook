require 'right_hook/authenticated_client'
require 'right_hook/logger'
require 'octokit'

module RightHook
  # Provides an interface for adding comments on GitHub
  class Commenter < AuthenticatedClient
    def comment_on_issue(owner, repo_name, issue_number, comment)
      result = client.add_comment("#{owner}/#{repo_name}", issue_number, comment)
      RightHook.logger.info("Result of comment_on_issue: #{result}")
    end
  end
end
