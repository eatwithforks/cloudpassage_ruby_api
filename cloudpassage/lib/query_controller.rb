# encoding: utf-8
require 'json'
require_relative 'validate'

# Returns custom query parameters
class Query
  def initialize(resp)
    Validate.response(resp, 200)
    @resp = resp
  end

  def fetch_params
    data = JSON.parse(@resp)
    return data unless data.key? 'pagination'

    data['per_page'] = current_per_page(data['pagination']['next'])
    data['pages'] = current_pages(data['per_page'], data['count'])
    data['filters'] = current_filters(data['pagination']['next'])
    data['primary_key'] = primary_key(data.keys)
    data
  end

  def current_per_page(next_page_url)
    next_page_url.match(/per_page=(\d+)/)[1].to_i
  end

  def current_pages(per_page, data_count)
    (2..(data_count / per_page.to_f).ceil).to_a
  end

  def remove_hostname(next_page_url)
    next_page_url.match(/\/v\d.*/).to_s
  end
  def current_filters(next_page_url)
    cleaned_url = remove_hostname(next_page_url)
    params = cleaned_url.split('?')
    "#{params.first}?" + clean_page_attrs(params).join('&')
  end

  def clean_page_attrs(data)
    data.last.split('&').delete_if { |e| e.match /page=\d+/ }
  end

  def primary_key(keys)
    blacklist = %w(count pagination per_page pages filters)
    keys.delete_if { |e| blacklist.include? e }.first
  end
end
