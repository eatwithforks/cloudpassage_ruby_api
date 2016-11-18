require_relative 'test_helper'

# test class
class Foo
  def code
    200
  end
end

# test Validate module
class ValidateTest < Minitest::Test
  def test_matching_response
    foo = Foo.new
    assert_nil Validate.response(foo, 200)
  end

  def test_raise_response
    begin
      foo = Foo.new
      captured = nil
      Validate.response(foo, 500)
    rescue RuntimeError => e
      captured = e.to_s
    end
    assert_equal "200 is returned. #{foo}", captured
  end
end
