# Captain Hook

[![Build Status](https://travis-ci.org/mark-rushakoff/captain_hook.png?branch=master)](https://travis-ci.org/mark-rushakoff/captain_hook)
[![Code Climate](https://codeclimate.com/github/mark-rushakoff/captain_hook.png)](https://codeclimate.com/github/mark-rushakoff/captain_hook)

Captain Hook simplifies setting up a web app to handle GitHub repo hooks.

## Installation

Add this line to your application's Gemfile:

    gem 'captain_hook'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install captain_hook

## Usage

### GitHub Authentication

To create hooks on GitHub repositories, you need to be authenticated as a collaborator on that repository.
GitHub's UI currently only supports configuring push hooks, so you'll want to authenticate through Captain Hook to set up custom hooks.

Captain Hook never stores your password.
He always uses OAuth tokens.
The only time he asks for your password is when he is creating a new token or listing existing tokens.

Captain Hook doesn't store your tokens, either.
It's your duty to manage storage of tokens.

### Subscribing to Hooks

Captain Hook provides a way to subscribe to hooks.
It's easy!

```ruby
require 'captain_hook'

default_opts = {
  base_url: "http://captain-hook.example.com",
  oauth_token: ENV['CAPTAIN_HOOK_TOKEN']
}

subscriber = CaptainHook::Subscriber.new(default_opts)

subscriber.subscribe(
  owner: 'octocat',
  repo_name: 'Hello-World',
  event_type: 'pull_request',
  secret: 'secret_for_hello_world'
)

subscriber.subscribe(
  owner: 'octocat',
  repo_name: 'Spoon-Knife',
  event_type: 'issue',
  secret: 'secret_for_spoon_knife'
)
```

(For more details, consult the RDoc documentation.)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
