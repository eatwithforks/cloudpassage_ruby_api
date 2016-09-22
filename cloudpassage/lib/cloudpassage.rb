# encoding: utf-8
require 'rest-client'
require_relative 'oauth'

class Api
  def initialize(key_id, secret_key, hostname = nil)
    hostname ||= ENV['api_hostname']
    token = ApiToken.token(key_id, secret_key, hostname)['access_token']
    @key_id, @secret_key, @hostname = key_id, secret_key, hostname
    @header = {
      'Authorization': "Bearer #{token}",
      'Content-type': 'application/json;charset=UTF=8',
      'Cache-Control': 'no-store',
      'Pragma': 'no-cache'
    }
  end

  def get(url)
    do_analyze({ method: :get, url: "#{@hostname}/#{url}" })
  end

  def post(url, body)
    do_analyze({ method: :post, url: "#{@hostname}/#{url}", payload: body })
  end

  def put(url, body)
    do_analyze({ method: :put, url: "#{@hostname}/#{url}", payload: body })
  end

  def delete(url)
    do_analyze({ method: :delete, url: "#{@hostname}/#{url}" })
  end

  protected

  def do_analyze(body)
    begin
      retries ||= 0
      body[:headers] = @header
      resp = RestClient::Request.execute(body) { |response| response }
      raise if resp.code == 401
      return resp
    rescue
      @header = renew_session
      retry if (retries += 1) < 3
    end
  end

  def renew_session
    token = ApiToken.token(@key_id, @secret_key, @hostname)['access_token']
    {
      'Authorization': "Bearer #{token}",
      'Content-type': 'application/json;charset=UTF=8',
      'Cache-Control': 'no-store',
      'Pragma': 'no-cache'
    }
  end
end
