# encoding: utf-8
require 'rest-client'
require_relative 'oauth'

class Api
  def initialize(key_id, secret_key, hostname)
    token = ApiToken.token(key_id, secret_key, hostname)['access_token']

    @header = {
      'Authorization': "Bearer #{token}",
      'Content-type': 'application/json;charset=UTF=8',
      'Cache-Control': 'no-store',
      'Pragma': 'no-cache'
    }
    @hostname = hostname
  end

  def get(url)
    RestClient.get("#{@hostname}/#{url}", @header) { |response| [response, JSON.parse(response)] }
  end

  def post(url, body)
    RestClient.post("#{@hostname}/#{url}", body, @header) { |response| [response, JSON.parse(response)] }
  end

  def put(url, body)
    RestClient.put("#{@hostname}/#{url}", body, @header) { |response| response }
  end

  def delete(url)
    RestClient.delete("#{@hostname}/#{url}", @header) { |response| response }
  end
end
