require 'openssl'
require 'uri'

module RightHook
  # Helpers for specs!
  # Typical usage is to include this module into your spec context, just like you would with Rack::Test::Methods.
  module SpecHelpers
    # Post to the given path, including the correct signature header based on the payload and secret.
    # @param [Hash] opts The options to use when crafting the request.
    # @option opts [String] :path The full path of the endpoint to which to post
    # @option opts [String] :payload A JSON-parseable string containing a payload as described in http://developer.github.com/v3/activity/events/types/
    # @option opts [String] :secret The secret to use when calculating the HMAC for the X-Hub-Signature header
    def post_with_signature(opts)
      path = opts.fetch(:path)
      payload = opts.fetch(:payload)
      secret = opts.fetch(:secret)

      post path, {payload: payload}, generate_secret_header(secret, URI.encode_www_form(payload: payload))
    end

    # :nodoc:
    def generate_secret_header(secret, body)
      sha = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), secret, body)
      # GitHub sends it as 'X-Hub-Signature', but Rack provides it as HTTP_X_HUB_SIGNATURE... :/
      {'HTTP_X_HUB_SIGNATURE' => "sha1=#{sha}"}
    end
  end
end
