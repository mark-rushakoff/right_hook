require 'openssl'

module CaptainHook
  module SpecHelpers
    def generate_secret_header(secret, body)
      sha = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), secret, body)
      {'X-Hub-Signature' => "sha1=#{sha}"}
    end
  end
end
