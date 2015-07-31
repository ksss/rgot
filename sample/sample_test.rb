require_relative './sample'

module SampleTest
  def test_sum(t)
    sample = Sample.new
    sum = sample.sum(3, 2)
    if !sum.kind_of?(Fixnum)
      t.error("expect Fixnum instance got #{sum}")
    end
    t.log("wow! first check was passed!")
    if sum != 5
      t.error("expect 5 got #{sum}")
    end
  end
end
