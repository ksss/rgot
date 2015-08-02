rgot
===

[![Build Status](https://travis-ci.org/ksss/rgot.svg)](https://travis-ci.org/ksss/rgot)

Ruby + Golang Testing = Rgot

Rgot is a testing package convert from golang testing.

### usage

test/sample.rb
```ruby
class Sample
  def sum(i, j)
    i + j
  end
end
```

test/pass_test.rb
```ruby
require_relative './sample'

module SampleTest
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
        t.error("expect 5 got #{sum}")
      end
    end
  end
end
```

```
$ rgot -v test/pass_test.rb
=== RUN test_pass
--- PASS: test_pass (0.00003s)
PASS
ok	0.001s
```
