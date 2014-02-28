module RightHook
  module Event
    class << self
      def github_name(event_type)
        case event_type
        when ISSUE
          'issues'
        when PULL_REQUEST
          'pull_request'
        when ISSUE_COMMENT
          'issue_comment'
        else
          raise ArgumentError, "Unrecognized event_type: #{event_type}"
        end
      end
    end

    ISSUE = 'issue'.freeze
    PULL_REQUEST = 'pull_request'.freeze
    ISSUE_COMMENT = 'issue_comment'.freeze

    KNOWN_TYPES = [
      ISSUE,
      PULL_REQUEST,
      ISSUE_COMMENT
    ].freeze
  end
end
