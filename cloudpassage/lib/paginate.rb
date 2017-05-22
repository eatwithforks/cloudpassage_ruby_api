# encoding: utf-8
require_relative 'cloudpassage'

class Paginate
  class << self
    def has_pagination?(resp)
      data = JSON.parse(resp)

      return data unless data.key? 'pagination' and data['pagination'].key? 'next'

      pkey = determine_primary_key(data)
      return data unless pkey.size == 1

      return data, pkey.first
    end

    def determine_primary_key(data)
      (data.keys - %w(count pagination))
    end

    def determine_next_url(data)
      /.com(.*?)(.*)$/.match(data['pagination']['next'])[2]
    end

    def paginate(resp)
      data, pkey = has_pagination?(resp)
      return data if pkey.nil?

      paged_data = data
      loop do
        next_page = determine_next_url(data)
        resp = yield next_page
        data = JSON.parse(resp)
        paged_data[pkey] << data[pkey]

        break unless data['pagination'].key? 'next'
      end

      paged_data[pkey].flatten!
      paged_data
    end
  end
end
