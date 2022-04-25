require_relative './sample'

module FatalTest
  def test_fatal(t)
    s = Sample.new
    sum = s.sum(nil, nil)
    unless sum.kind_of?(Integer)
      t.error("expect Integer got #{sum.class}")
    end
    unless sum == 5
      t.error("expect 5 got #{sum}")
    end
  end
end
