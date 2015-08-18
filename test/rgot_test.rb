require 'open3'

module RgotTest
  # This method should be running before testing
  def test_main(m)
    exit m.run
  end

  def test_pass(t)
    cmd = "bin/rgot test/pass_test.rb -v"
    out = `#{cmd}`
    if /---\sPASS:\s.*/ !~ out
      t.error("expect PASS `#{cmd}` got #{out}")
    end
  end

  def test_fail(t)
    cmd = "bin/rgot test/fail_test.rb -v"
    out = `#{cmd}`
    if /---\sFAIL:\s.*/ !~ out
      t.error("expect FAIL `#{cmd}` got #{out}")
    end
  end

  def test_fatal(t)
    cmd = "bin/rgot test/fatal_test.rb -v"
    out, err, status = Open3.capture3(cmd)
    if status.success?
      t.error("expect process not success `#{cmd}` got #{status}")
    end
    if /`sum': undefined method `\+' for nil:NilClass \(NoMethodError\)/ !~ err
      error_class = err.match(/\((.*?)\)/)[1]
      t.log(err)
      t.error("expect NoMethodError got #{error_class}")
    end
    if /---\sFAIL:\s.*/ !~ out
      t.error("expect FAIL `#{cmd}` got #{out}")
    end
  end

  def test_skip(t)
    cmd = "bin/rgot test/skip_test.rb -v"
    out = `#{cmd}`
    if /skip testing/ !~ out
      t.error("expect skip `#{cmd}` got #{out}")
    end
  end

  def test_timeout(t)
    cmd = "bin/rgot test/timeout_test.rb -v --timeout 0.1"
    out, err, status = Open3.capture3(cmd)
    if status.success?
      t.error("expect process not success `#{cmd}` got #{status}")
    end
    if /`sleep': execution expired \(Timeout::Error\)/ !~ err
      error_class = err.match(/\((.*?)\)/)[1]
      t.log(err)
      t.error("expect NoMethodError got #{error_class}")
    end
    if /^ok\s+\d/ =~ out
      t.error("expect not print 'ok' got #{out}")
    end
  end

  def test_main_method(t)
    cmd = "bin/rgot test/main_test.rb -v"
    out = `#{cmd}`
    if /start in main.*?run testing.*?end in main/m !~ out
      t.error("expect output start -> run -> end got '#{out}'")
    end
  end

  def test_main_method_return_code(t)
    code = Rgot::M.new(tests: [], benchmarks: [], examples: [], opts: {}).run
    unless Integer === code
      t.error("Rgot::M#run return expect to exit code, got #{code}")
    end
  end

  def test_benchmark(t)
    cmd = "bin/rgot test/benchmark_test.rb --benchtime 0.4 --bench sum"
    out = `#{cmd}`
    if /benchmark_sum\s+\d+\s+\d+\.\d+\s+ns\/op/ !~ out
      t.error("expect output benchmark report. got #{out}")
    end
  end

  def test_benchmark_parallel(t)
    cmd = "bin/rgot test/benchmark_test.rb --benchtime 0.1 --bench parallel --cpu=2,4"
    out = `#{cmd}`
    expect_out = <<-OUT.chomp
benchmark_parallel-2\\s+\\d+\\s+\\d+\\.\\d+\\s+ns/op
benchmark_parallel-4\\s+\\d+\\s+\\d+\\.\\d+\\s+ns/op
ok\\s+BenchmarkTest\\s+\\d+.\\d+s
OUT
    if /#{expect_out}/m !~ out
      p /#{expect_out}/m
      t.error("expect match out. got #{out}")
    end
  end

  def test_example_pass(t)
    cmd = "bin/rgot test/example_pass_test.rb"
    out = `#{cmd}`.chomp
    if /ok\s+ExamplePassTest/ !~ out
      t.error("want PASS got '#{out}'")
    end
  end

  def test_example_fail(t)
    cmd = "bin/rgot test/example_fail_test.rb"
    out = `#{cmd}`
    expect_out = <<-OUT.chomp
got:
Hello
I'm example
want:
bye
I'm fail
got:
ok go
want:
ng back
FAIL
FAIL	ExamplePassTest
OUT
    if out.index(expect_out) != 0
      t.error("\n--- expect:\n#{expect_out}\n--- got:\n#{out}\n")
    end
  end

  def test_single_dir(t)
    cmd = "bin/rgot -v test/foo"
    out = `#{cmd}`
    if /test_foo is ok.*?PASS/m !~ out
      t.error("want PASS got '#{out}'")
    end
  end

  def test_multi_dir_and_module(t)
    cmd = "bin/rgot -v test/bar test/bar/baz"
    out = `#{cmd}`
    if /test_bar is ok.*?PASS.*?test_baz is ng.*?FAIL/m !~ out
      t.error("want PASS and FAIL massage got '#{out}'")
    end
  end

  def test_rgot_benchmark(t)
    result = Rgot.benchmark(benchtime: 0.1) { |b|
      unless Rgot::B === b
        t.error("expect instance of Rgot::B got #{b.class}")
      end
      unless 0 < b.n
        t.error("aaa")
      end
    }
    unless Rgot::BenchmarkResult === result
      t.error("expect instance of Rgot::BenchmarkResult got #{result.class}")
    end
  end
end
