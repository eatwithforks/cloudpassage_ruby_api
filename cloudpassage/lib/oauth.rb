# encoding: utf-8
require 'rest-client'
require 'json'
require 'base64'

class ApiToken
  URL = 'oauth/access_token?grant_type=client_credentials'
  class << self
    def token(key_id, secret_key, hostname)
      RestClient.post(
        "#{hostname}/#{URL}",
        '',
        header(base64(key_id, secret_key))) { |response| JSON.parse(response) }
    end

    def base64(key_id, secret_key)
      Base64.encode64("#{key_id}:#{secret_key}")
    end

    def header(base64_str)
      { 'Authorization': "Basic #{base64_str}" }
    end
  end
end
