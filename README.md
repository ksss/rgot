Rgot
===

[![Ruby](https://github.com/ksss/rgot/actions/workflows/main.yml/badge.svg)](https://github.com/ksss/rgot/actions/workflows/main.yml)

Ruby + Golang Testing = Rgot

Rgot is a testing package convert from golang testing.

### Usage

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
      unless sum.kind_of?(Integer)
        t.error("expect Integer got #{sum.class}")
      end
      unless sum == ts.expect
        t.error("expect #{ts.expect} got #{sum}")
      end
    end
  end
end
```

```
$ rgot -v --require ./test/sample test/pass_test.rb
=== RUN test_pass
--- PASS: test_pass (0.00003s)
PASS
ok	0.001s
```

# Features

## Testing

I provide a very simple testing feature to you.

**Rgot** testing is quite different from *RSpec* and *MiniTest* etc.

Rgot carve out a new world of testing.

So, You check only bad case in testing.

## Benchmark

You can write simple benchmark script with testing.

This benchmark to adjust the time automatically.

```ruby
module FooTest
  def benchmark_something(b)
    i = 0
    while i < b.n
      something(1)
      i += 1
    end
  end
end
```

```
$ rgot foo_test.rb --bench .
benchmark_something	14400000	81 ns/op
ok	FooTest	2.782s
```

`b.n` is automatically adjusted.

## Fuzzing

```
$ rgot target_file_test.rb --fuzz . --fuzztime 1
```

Fuzzing tests are also supported.
Please refer to the gloang documentation for details.

https://go.dev/security/fuzz/

```ruby
module FooTest
  # To enable fuzzing, the method name
  # should be prefixed with `fuzz`.
  def fuzz_any_func(f)
    f.add(5, "hello")
    f.fuzz do |t, i, s|
      out, err = foo(i, s)
      if err != nil && out != ""
        t.errorf("%s, %s", out, err)
      end
    end
  end
end
```

## Example

Rgot's example feature is the best and if you want to write the sample code of your library.

While presenting the sample code, it will be able to test whether the display results match at the same time.

```ruby
module FooTest
  class User
    def initialize(name)
      @name = name
    end

    def hello
      "Hello #{@name}"
    end
  end

  def example_something
    user = User.new('ksss')
    puts user.hello
    # Output:
    # Hello ksss
  end

  def example_fail
    user = User.new('ksss')
    puts user.hello
    # Output:
    # Hi ksss
  end
end
```

`example_fail` fail since output is different.

So, you can notice that the sample code is wrong.

# Table Driven Tests

```rb
FLAGTESTS = [
  ["%a", "[%a]"],
  ["%-a", "[%-a]"],
  ["%+a", "[%+a]"],
  ["%#a", "[%#a]"],
  ["% a", "[% a]"],
  ["%0a", "[%0a]"],
  ["%1.2a", "[%1.2a]"],
  ["%-1.2a", "[%-1.2a]"],
  ["%+1.2a", "[%+1.2a]"],
  ["%-+1.2a", "[%+-1.2a]"],
  ["%-+1.2abc", "[%+-1.2a]bc"],
  ["%-1.2abc", "[%-1.2a]bc"],
]

def test_flag_parser(t)
  FLAGTESTS.each do |input, output|
    s = Flag.print(input)
    unless s == output
      t.errorf("Flag.print(%p) => %p, want %p", input, s, output)
    end
  end
end
```

see https://github.com/golang/go/wiki/TableDrivenTests

# Naming convention

## Filename

Filename should be set '*_test.rb'

## Module name

Module name should be set 'XxxTest'

'Xxx' can replace any string (in range of ruby module)

Testing code file can split any number.

But all file should be have one module (like golang package name).

```ruby
module XxxTest
  # ...
end
```

## Method name

Method name should be set `test_*` for testing.

And benchmark method should be set `benchmark_*`.

And fuzz method should be set `fuzz_*`.

And example method should be set `example_*`.

```ruby
module XxxTest
  def test_any_name(t)
  end

  def benchmark_any_name(b)
  end

  def fuzz_any_name(f)
  end

  def example_any_name
  end
end
```

# Command line interface

```
$ rgot -h
Usage: rgot [options]
    -v, --verbose                    log all tests
        --version                    show Rgot version
        --bench [regexp]             benchmark
        --benchtime [sec]            benchmark running time
        --timeout [sec]              set timeout sec to testing
        --cpu [count,...]            set cpu counts of comma split
        --thread [count,...]         set thread counts of comma split
        --require [path]             load some code before running
        --load-path [path]           Specify $LOAD_PATH directory
        --fuzz [regexp]              run the fuzz test matching `regexp`
        --fuzztime [sec]             time to spend fuzzing; default is to run indefinitely
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

Show all log and more detail information of testing.

## Benchmark

```
$ rgot target_file_test.rb --bench .
```

Run testing with benchmark.

`.` means match all string for regexp.

Set `someone` if you only run benchmark to match `someone` method.(e.g. benchmark_someone_1)

### Parallel benchmark

Benchmark for parallel performance.

`--cpu` option set process counts (default `Etc.nprocessors`).

And `--thread` option set thread counts (default 1).

Benchmark fork, run and report each by process counts.

(**process** and **thread** means ruby/linux native process and thread)

```ruby
module FooTest
  def benchmark_any_func(b)
    b.run_parallel do |pb|
      # pb is instance of Rgot::PB
      # call some time by b.n
      while pb.next
        some_func()
      end
    end
  end
end
```

```
$ rgot foo_test.rb --bench . --cpu=2,4 --thread=2,4
benchmark_any_func-2(2)	40	13363604 ns/op
benchmark_any_func-2(4)	160	7125845 ns/op
benchmark_any_func-4(2)	160	7224815 ns/op
benchmark_any_func-4(4)	320	3652431 ns/op
ok	FooTest	3.061s
```

## Timeout

```
$ rgot target_file_test.rb --timeout 3
```

You can set timeout sec for testing (default 0).

Fail testing and print raised exception message to STDERR if timeout.

# Recommendation

Set up Rakefile.

```rb
# Rakefile
require "rake/testtask"
Rake::TestTask.new do |task|
  task.libs = %w[lib test]
  task.test_files = FileList["lib/**/*_test.rb"]
end
```

Set `test/test_helper.rb`.

```rb
# test/test_helper.rb
require "rgot/cli"

unless $PROGRAM_NAME.end_with?("/rgot")
  at_exit do
    exit Rgot::Cli.new(["-v", *ARGV]).run
  end
end
```

Place the test file in the same directory as the implementation file.
Just like in golang.

```console
$ ls lib
lib/foo.rb
lib/foo_test.rb
```

Write your testing code.

```rb
# lib/foo_test.rb
require 'test_helper'

module FooTest
  def test_foo(t)
    # ...
  end
end
```

OK, You will be able to both run all tests with rake and specify one file to run.

```console
$ bundle exec rake test
```

```console
$ bundle exec rgot lib/foo_test.rb
```

# Methods

## Rgot

### Rgot.benchmark

Run benchmark function without framework.

```ruby
result = Rgot.benchmark do |b|
  i = 0
  while i < b.n
    some_func()
    i += 1
  end
end
puts result #=> 100000	100 ns/op
```

### Rgot.verbose?

Check running with option verbose true/false.

## Rgot::M (Main)

Main method run first on testing.

And this is default virtual main code.

```ruby
module TestSomeCode
  def test_main(m)
    m.run
  end
end
```

Main method should be set 'test_main' only.

Variable `m` is a instance of `Rgot::M` class means Main.

`Rgot::M#run` start all testing methods.

And return code of process end status.

If you want to run before/after all testing method, You can write like this.

```ruby
module TestSomeCode
  def test_main(m)
    the_before_running_some_code
    code = m.run
    the_after_running_some_code
    code
  end
end
```

## Rgot::Common

`Rgot::Common` is inherited to `Rgot::T` and `Rgot::B`

`Rgot::Common` have some logging method.

### Rgot::Common#log

```ruby
t.log("wooooo", 1, 2, 3)
```

Write any log message.

But this message to show need -v option.

### Rgot::Common#logf

Write any log message like sprintf.

```ruby
t.logf("%d-%s", 10, "foo")
```

### Rgot::Common#error

```ruby
t.error("expect #{a} got #{b}")
```

Test fail and show some error message.

### Rgot::Common#errorf

Fail loggin same as logf

### Rgot::Common#fatal

Testing stop and fail with log.

```ruby
t.fatal("fatal error!")
```

### Rgot::Common#fatalf

Fatal logging same as logf

### Rgot::Common#skip

```ruby
t.skip("this method was skipped")
```

Skip current testing method.

And run to next testing method.

### Rgot::Common#skipf

Skip logging same as logf

## Rgot::T (Testing)

Testing is a main usage of this package.

```ruby
module TestSomeCode
  def test_some_1(t)
  end
end
```

The `t` variable is instance of `Rgot::T` class means Testing.

## Rgot::B (Benchmark)

For Benchmark class.

Can use log methods same as `Rgot::T` class

### Rgot::B#n

Automatic number calculated by running time.

Recommend to this idiom.

```ruby
def benchmark_something(b)
  i = 0
  while i < b.n
    something()
    i += 1
  end
end
```

### Rgot::B#reset_timer

Reset benchmark timer

```ruby
def benchmark_something(b)
  obj = heavy_prepare_method()
  b.reset_timer # you can ignore time of havy_prepare_method()
  i = 0
  while i < b.n
    obj.something()
    i += 1
  end
end
```

### Rgot::B#start_timer

Start benchmark timer

### Rgot::B#stop_timer

Stop benchmark timer

### Rgot::B#run_parallel

Start parallel benchmark using `fork` and `Thread.new`.

This method should be call with block.

The block argument is instance of Rgot::PB.

## Rgot::PB (Parallel Benchmark)

### Rgot::PB#next

Should be call this when parallel benchmark.

Repeat while return false.

Recommend this idiom.

```ruby
def benchmark_foo(b)
  b.run_parallel do |pb|
    while pb.next
      some_func()
    end
  end
end
```

## Rgot::F (Fuzzing)

### Rgot::F#add

Set the sample value with `#add`. This value is also used as a test. It guesses the type from the value and generates a random value.

### Rgot::F#fuzz

Generate the random value generated by `#fuzz` and execute the code.
The `t` becomes an instance of `Rgot::T` and the test can be run as usual.

```ruby
def fuzz_foo(f)
  f.add(100, "hello")
  f.fuzz do |t, i, s|
    i #=> 100, 84, 17, 9, 66, ...
    s #=> "hello", "Y\xD5\xAB\xBA\x8E", "r\x95D\xA5\xF7", "\xCEj=\x9C\xBD", ...
    if !foo(i, s)
      t.error("fail with i=#{i}, s=#{s}")
    end
  end
end
```

# TODO

- [ ] Support to save and load fuzzing data

## v2

- [ ] Support sub testing
- [ ] Fix duration argument unit
- [ ] Refactoring
  - [ ] Fix M#initialize argument
  - [ ] Fix internal class API
