# encoding: utf-8
require 'rest-client'
require 'parallel'
require_relative 'oauth'
require_relative 'validate'
require_relative 'query_controller'

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

  def get_paginated(url)
    data = Query.new(get(url)).fetch_params
    return data unless data.key? 'pagination'

    fetch_entire_data(url, data)
  end

  protected

  def do_analyze(body)
    begin
      retries ||= 0
      body[:headers] = @header
      resp = RestClient::Request.execute(body) { |response| response }
      raise if resp.code == 401 or resp.code.to_s.match(/^5.*/)
      return resp
    rescue
      if resp.code == 401
        @header = renew_session
        retry if (retries += 1) < MAX_RETRIES
      elsif resp.code.to_s.match(/^5.*/)
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
    %w(per_page pages filters primary_key)
  end

  def fetch_entire_data(url, data)
    pkey = data['primary_key']
    data['pages'].each do |page|
      resp = get("#{data['filters']}&page=#{page}")
      Validate.response(resp, 200)

      paged_data = JSON.parse(resp)
      data[pkey] << paged_data[pkey]
    end

    data[pkey].flatten!
    blacklist.map { |key| data.delete(key) }
    data
  end
end
