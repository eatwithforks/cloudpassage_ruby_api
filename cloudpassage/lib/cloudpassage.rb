# encoding: utf-8
require 'rest-client'
require 'parallel'
require_relative 'oauth'

# Returns CloudPassage API HTTP requests
class Api
  def initialize(key_id, secret_key, hostname = nil)
    hostname ||= ENV['api_hostname']
    token = ApiToken.token(key_id, secret_key, hostname)['access_token']
    create_header(token)

    @key_id = key_id
    @secret_key = secret_key
    @hostname = hostname
  end

  def get(url)
    do_analyze(method: :get, url: "#{@hostname}/#{url}")
  end

  def post(url, body)
    do_analyze(method: :post, url: "#{@hostname}/#{url}", payload: body)
  end

  def put(url, body)
    do_analyze(method: :put, url: "#{@hostname}/#{url}", payload: body)
  end

  def delete(url)
    do_analyze(method: :delete, url: "#{@hostname}/#{url}")
  end

  protected

  def do_analyze(body)
    retries ||= 0
    body[:headers] = @header
    resp = RestClient::Request.execute(body) { |response| response }
    raise if resp.code == 401
    return resp
  rescue
    renew_session
    retry if (retries += 1) < 3
  end

  def renew_session
    token = ApiToken.token(@key_id, @secret_key, @hostname)['access_token']
    create_header(token)
  end

  def create_header(token)
    @header = {
      authorization: "Bearer #{token}",
      content_type: 'application/json;charset=UTF=8',
      cache_control: 'no-store',
      pragma: 'no-cache'
    }
  end
end
