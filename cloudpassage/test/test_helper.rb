$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cloudpassage'

require 'minitest/autorun'

def mock_api_token
  @api_token = MiniTest::Mock.new
  @api_token.expect :token, 'my-token', ['key-123', 'secret-456', 'fake-portal']
end

def mock_api
  @api = MiniTest::Mock.new
  @api.expect :new, true, ['key-123', 'secret-456']
  @api.expect :create_header, @header, ['foo']
end
