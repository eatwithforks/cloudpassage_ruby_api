require_relative 'test_helper'

# test ApiToken class
class OAuthTest < Minitest::Test
  def test_oauth_header
    expected = { 'Authorization': 'Basic foo' }
    header = ApiToken.header('foo')

    assert_equal expected, header
  end

  def test_oauth_base64
    base64 = ApiToken.base64('foo', 'bar')
    assert_equal "Zm9vOmJhcg==\n", base64
  end
end
