require_relative './sample'

module FailTest
  def test_fail(t)
    s = Sample.new
    sum = s.sum(2.0, 3)
    unless sum.kind_of?(Integer)
      t.error("expect Integer got #{sum.class}")
    end
    unless sum == 5
      t.error("expect 5 got #{sum}")
    end
  end
end
