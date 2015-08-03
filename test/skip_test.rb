require_relative './sample'

module SkipTest
  def test_skip(t)
    t.skip "skip testing"
    raise "expect to unreach"
  end
end
