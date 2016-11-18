require_relative 'test_helper'
require 'cloudpassage'

def mocks
  @api_token = MiniTest::Mock.new
  @api_token.expect :token, 'my-token', ['key-123', 'secret-456', 'fake-portal']

  @api = MiniTest::Mock.new
  @api.expect :new, true, ['key-123', 'secret-456']
  @api.expect :create_header, @header, ['foo']
end

class CloudpassageTest < Minitest::Test
  def setup
    @header = {
      authorization: 'Bearer foo',
      content_type: 'application/json;charset=UTF=8',
      cache_control: 'no-store',
      pragma: 'no-cache'
    }

    mocks
  end

  def test_that_it_has_a_version_number
    refute_nil ::Cloudpassage::VERSION
  end

  def test_initialize
    assert @api.new('key-123', 'secret-456')
  end

  def test_new_invalid_params
    assert_raises(ArgumentError) { Api.new('key-123') }
  end

  def test_create_header
    assert_equal @header, @api.create_header('foo')
  end

  def test_api_token
    token = @api_token.token('key-123', 'secret-456', 'fake-portal')
    assert_equal 'my-token', token
  end
end
