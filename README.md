# Right Hook

[![Build Status](https://travis-ci.org/mark-rushakoff/right_hook.png?branch=master)](https://travis-ci.org/mark-rushakoff/right_hook)
[![Code Climate](https://codeclimate.com/github/mark-rushakoff/right_hook.png)](https://codeclimate.com/github/mark-rushakoff/right_hook)
[![Coverage Status](https://coveralls.io/repos/mark-rushakoff/right_hook/badge.png)](https://coveralls.io/r/mark-rushakoff/right_hook)
[![Gem Version](https://badge.fury.io/rb/right_hook.png)](http://badge.fury.io/rb/right_hook)

Right Hook is a collection of tools to aid in setting up a web app to handle GitHub repo hooks.

To see some example usage, head over to [right-hook/hookbooks](https://github.com/right-hook/hookbooks).

To see the documentation for the current version of the gem, visit [rubydoc.info](http://rubydoc.info/gems/right_hook).

## Installation

Add this line to your application's Gemfile:

    gem 'right_hook'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install right_hook

## Usage

### Your App

Create an application by subclassing `RightHook::App`:

```ruby
# app.rb
require 'right_hook/app'
require 'right_hook/event'

class MyApp < RightHook::App
  # You must supply a secret for each repository and hook.
  # The secret should only be known by GitHub; that's how we know the request is coming from GitHub's servers.
  # (You'll specify that secret when you go through subscription.)
  def secret(owner, repo_name, event_type)
    if owner == 'octocat' && repo_name == 'Spoon-Fork' && event_type == RightHook::Event::PULL_REQUEST
      'qwertyuiop'
    else
      raise 'unrecognized!'
    end
  end

  # Code to execute for GitHub's pull request hook.
  # The secret has already been verified if your code is being called.
  # See app.rb and spec/app/*_spec.rb for signatures and examples of the valid handlers.
  def on_pull_request(owner, repo_name, action, pull_request_json)
    message = <<-MSG
      GitHub user #{pull_request_json['user']['login']} has opened pull request ##{pull_request_json['number']}
      on repository #{owner}/#{repo_name}!
    MSG
    send_text_message(MY_PHONE_NUMBER, message) # or whatever you want
  end
end
```

You'll need to host your app online and hold on to the base URL so you can subscribe to hooks.

### GitHub Authentication

To create hooks on GitHub repositories, you need to be authenticated as a collaborator on that repository.
GitHub's UI currently only supports configuring push hooks, so you'll want to authenticate through Right Hook to set up custom hooks.

Right Hook never stores your password; instead, it always uses OAuth tokens.
The only time it asks for your password is when it is creating a new token or listing existing tokens.

Right Hook doesn't store your tokens, either.
It's your duty to manage storage of tokens.
Typically, tokens and other secret values are stored as environment variables for your app, rather than in a flat file or in a database.

Here's one way you can generate and list tokens:

```ruby
require 'right_hook/authenticator'

puts "Please enter your username:"
username = $stdin.gets

# Prompt the user for their password, without displaying it in the terminal
authenticator = RightHook::Client.interactive_build(username)

# Note for the token (this will be displayed in the user's settings on GitHub)
note = "Created in my awesome script"
authenticator.find_or_create_authorization_by_note(note)

authenticator.authorizations.each do |token|
  puts "Token: #{auth.token}\nNote: #{auth.note}\n\n"
end
```

### Subscribing to Hooks

Right Hook provides a way to tell GitHub you want to subscribe your Right Hook application to GitHub's hooks.
It's easy!

```ruby
require 'right_hook/subscriber'

default_opts = {
  base_url: "http://right-hook.example.com",
  oauth_token: ENV['RIGHT_HOOK_TOKEN']
}

subscriber = RightHook::Subscriber.new(default_opts)

subscriber.subscribe(
  owner: 'octocat',
  repo_name: 'Hello-World',
  event_type: RightHook::Event::PULL_REQUEST,
  secret: 'secret_for_hello_world'
)
```

(For more details, consult the RDoc documentation.)

## License

Available under the terms of the MIT license.
See [license.txt](license.txt) for details.

## Help

Is any documentation unclear?
Did you expect that Right Hook was going to help you in a particular way, and then it didn't?
Please open an issue!
One of the best ways to improve open source software is to make your needs known.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
