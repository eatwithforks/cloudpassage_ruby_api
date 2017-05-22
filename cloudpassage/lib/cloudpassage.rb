# encoding: utf-8
require 'rest-client'
require 'parallel'
require_relative 'oauth'
require_relative 'validate'
require_relative 'paginate'

# Returns CloudPassage API HTTP requests
class Api
  MAX_RETRIES = 5
  RETRY_DELAYS = [2, 8, 15, 45, 90]

  def initialize(key_id, secret_key, hostname = nil)
    hostname ||= ENV['api_hostname']
    token = ApiToken.token(key_id, secret_key, hostname)['access_token']
    create_header(token)

    @key_id = key_id
    @secret_key = secret_key
    @hostname = hostname
    @timeout = 90000000
  end

  def get(url)
    perform({ method: :get, url: "#{@hostname}/#{url}", timeout: @timeout })
  end

  def post(url, body)
    perform({ method: :post, url: "#{@hostname}/#{url}", payload: body, timeout: @timeout })
  end

  def put(url, body)
    perform({ method: :put, url: "#{@hostname}/#{url}", payload: body, timeout: @timeout })
  end

  def delete(url)
    perform({ method: :delete, url: "#{@hostname}/#{url}", timeout: @timeout })
  end

  def get_paginated(url)
    Paginate.paginate(get(url)) { |next_page| get(next_page) }
  end

  protected

  def perform(body)
    begin
      retries ||= 0
      body[:headers] = @header
      resp = RestClient::Request.execute(body) { |response| response }
      raise if resp.code == 401 or resp.code >= 500

      return resp
    rescue
      if resp.code == 401
        @header = renew_session
        retry if (retries += 1) < MAX_RETRIES
      elsif resp.code >= 500
        sleep RETRY_DELAYS[retries]
        retry if (retries += 1) < MAX_RETRIES
      end
    end
  end

  def renew_session
    token = ApiToken.token(@key_id, @secret_key, @hostname)['access_token']
    create_header(token)
  end

  def create_header(token)
    @header = {
      'Authorization': "Bearer #{token}",
      'Content-type': 'application/json;charset=UTF=8',
      'Cache-Control': 'no-store',
      'Pragma': 'no-cache'
    }
  end
end
