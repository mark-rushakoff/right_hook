require 'openssl'

module RightHook
  module SpecHelpers
    def generate_secret_header(secret, body)
      sha = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), secret, body)
      # GitHub sends it as 'X-Hub-Signature', but Rack provides it as HTTP_X_HUB_SIGNATURE... :/
      {'HTTP_X_HUB_SIGNATURE' => "sha1=#{sha}"}
    end
  end
end
