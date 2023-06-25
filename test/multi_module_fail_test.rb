module FooTest
  def test_foo(t)
    raise "should not call"
  end
end

module BarTest
  def test_bar(t)
    raise "should not call"
  end
end
