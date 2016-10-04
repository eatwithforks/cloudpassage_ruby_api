# encoding: utf-8
require 'json'
require_relative 'validate'

# Returns custom query parameters
class Query
  def initialize(resp)
    Validate.response(resp, 200)
    @resp = resp
  end

  def fetch_params(api_hostname)
    data = JSON.parse(@resp)
    return @resp unless data.key? 'pagination'

    data['per_page'] = current_per_page(data['pagination']['next'])
    data['pages'] = current_pages(data['per_page'], data['count'])
    data['filters'] = current_filters(api_hostname, data['pagination']['next'])
    data
  end

  def current_per_page(next_page_url)
    next_page_url.match(/per_page=(\d+)/)[1].to_i
  end

  def current_pages(per_page, data_count)
    (2..(data_count / per_page.to_f).ceil).to_a
  end

  def current_filters(api_hostname, next_page_url)
    params = next_page_url.split(api_hostname).last.split('?')
    "#{params.first}?" + clean_page_attrs(params).join('&')
  end

  def clean_page_attrs(data)
    data.last.split('&').delete_if { |e| e.match /page=\d+/ }
  end
end
