rgot
===

RGOT is a Ruby Golang like Testing package.


### usage

lib/sample.rb
```ruby
class Sample
  def sum(i, j)
    i + j
  end
end
```

lib/sample_test.rb
```ruby
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
```

```
$ rgot -v lib
=== RUN test_sum
--- PASS: test_sum (0.00021s)
	sample/sample_test.rb:9: wow! first check was passed!
PASS
ok	0.001s
```
