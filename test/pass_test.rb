require_relative './sample'

module PassTest
  class TypeSum < Struct.new(:left, :right, :expect)
  end

  DATA = [
    TypeSum.new(2, 3, 5),
    TypeSum.new(12, 9, 21),
    TypeSum.new(85, 42, 127),
  ]

  def test_pass(t)
    s = Sample.new
    DATA.each do |ts|
      sum = s.sum(ts.left, ts.right)
      unless sum.kind_of?(Fixnum)
        t.error("expect Fixnum got #{sum.class}")
      end
      unless sum == ts.expect
        t.error("expect #{ts.expect} got #{sum}")
      end
    end
  end
end
