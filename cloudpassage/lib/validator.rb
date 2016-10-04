module Validate
  def self.response(resp, resp_code)
    raise "#{resp.code} is returned. #{resp}" unless resp.code.eql? resp_code
  end
end