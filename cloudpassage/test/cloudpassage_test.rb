require_relative 'test_helper'
require 'cloudpassage'

class CloudpassageTest < Minitest::Test
  def setup
    @header = {
      authorization: 'Bearer foo',
      content_type: 'application/json;charset=UTF=8',
      cache_control: 'no-store',
      pragma: 'no-cache'
    }

    mock_api
    mock_api_token
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
