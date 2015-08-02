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

# Naming convention

## Filename

Filename should be set '*_test.rb'

## Module name

Module name should be set 'TestXXX'

'XXX' can replace any string (in range of ruby module)

Testing code file can split any number.

But all file should be have one module (like golang package name).

```ruby
module TestXXX
end
```

## Method name

Method name should be set 'test_*' for testing.

And benchmark method should be set 'benchmark_*'.

```ruby
module TestXXX
  def test_any_name(t)
  end

  def benchmark_any_name(b)
  end
end
```

# Command

```
$ rgot -h
Usage: rgot [options]
    -v, --verbose                    log all tests
    -b, --bench [regexp]             benchmark
        --benchtime [sec]            benchmark running time
```

## Basic

```
$ rgot file_of_test.rb
PASS
ok	0.001s
```

Set filename to argument.

Just only start testing file_of_test.rb.

```
$ rgot sample
PASS
ok	0.002s
```

And set dirname to argument, run all case of testing under this dir.

## Verbose

```
$ rgot -v target_file_test.rb
=== RUN test_pass
--- PASS: test_pass (0.00005s)
PASS
ok	0.001s
```

Show all log and more detail infomation of testing.

## Benchmark

```
$ rgot target_file_test.rb -b .
```

Run testing with benchmark.

`.` means match all string for regexp.

Set `someone` if you only run benchmark to match `someone` method.(e.g. benchmark_someone_1)

# Rgot::M (Main)

Main method run first on testing.

And this is default virtual main code.

```ruby
module TestSomeCode
  def test_main(m)
    exit m.run
  end
end
```

Main method should be set 'test_main' only.

variable `m` is a instance of `Rgot::M` class means Main.

`Rgot::M#run` start all testing methods.

And return code of process end status.

If you want to run before/after all testing method, You can write like this.

```ruby
module TestSomeCode
  def test_main(m)
    the_before_running_some_code
    code = m.run
    the_after_running_some_code
    exit code
  end
end
```

# Rgot::T (Testing)

Testing is a main usage of this package.

```ruby
module TestSomeCode
  def test_some_1(t)
  end
end
```

The `t` variable is instance of `Rgot::T` class means Testing.

`Rgot::T` have some logging method.

## Rgot::T#log

```ruby
t.log("wooooo")
```

Write any log message.

But this message to show need -v option.

## Rgot::T#error

```ruby
t.error("expect #{a} got #{b}")
```

Test fail and show some error message.

# Rgot::B (Benchmark)

Can use log methods same as `Rgot::T` class

## Rgot::B#reset_timer

Reset benchmark timer

## Rgot::B#start_timer

Start benchmark timer

## Rgot::B#stop_timer

Stop benchmark timer
