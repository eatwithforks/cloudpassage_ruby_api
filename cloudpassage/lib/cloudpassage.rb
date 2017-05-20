# encoding: utf-8
require 'rest-client'
require 'parallel'
require_relative 'oauth'
require_relative 'validate'

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
  end

  def get(url)
    do_analyze({ method: :get, url: "#{@hostname}/#{url}", timeout: 90000000 })
  end

  def post(url, body)
    do_analyze({ method: :post, url: "#{@hostname}/#{url}", payload: body, timeout: 90000000 })
  end

  def put(url, body)
    do_analyze({ method: :put, url: "#{@hostname}/#{url}", payload: body, timeout: 90000000 })
  end

  def delete(url)
    do_analyze({ method: :delete, url: "#{@hostname}/#{url}", timeout: 90000000 })
  end

  def get_paginated(url)
    resp = get(url)
    data = JSON.parse(resp)
    return data unless data.key? 'pagination'

    paginate(data, determine_primary_key(data))
  end

  protected

  def do_analyze(body)
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

  def blacklist
    %w(count pagination)
  end

  def determine_primary_key(data)
    (data.keys - blacklist).first
  end

  def paginate(data, primary_key)
    return data unless data['pagination'].key? 'next'
    copy_data = data

    loop do
      next_page = /.com(.*?)(.*)$/.match(data['pagination']['next'])[2]
      resp = get(next_page)
      data = JSON.parse(resp)
      copy_data[primary_key] << data[primary_key]
      break unless data['pagination'].key? 'next'
    end

    copy_data[primary_key].flatten!
    copy_data
  end
end
