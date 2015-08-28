require 'open3'

module RgotTest
  # This method should be running before testing
  def test_main(m)
    exit m.run
  end

  def test_common_log(t)
    c = Rgot::Common.new
    c.log(1, 2, 3)
    if /1 2 3/ !~ c.output
      t.error("expect output '1 2 3' got #{c.output.inspect}")
    end
  end

  def test_common_logf(t)
    c = Rgot::Common.new
    c.logf("%d-%d-%d", 1, 2, 3)
    if /1-2-3/ !~ c.output
      t.error("expect output '1-2-3' got #{c.output.inspect}")
    end
  end

  def test_common_error(t)
    c = Rgot::Common.new
    c.error(1, 2, 3)
    if /1 2 3/ !~ c.output
      t.error("expect output '1 2 3' got #{c.output.inspect}")
    end
    unless c.failed?
      t.error("expect status 'failed' but not")
    end
  end

  def test_common_errorf(t)
    c = Rgot::Common.new
    c.errorf("%d-%d-%d", 1, 2, 3)
    if /1-2-3/ !~ c.output
      t.error("expect output '1-2-3' got #{c.output.inspect}")
    end
    unless c.failed?
      t.error("expect status 'failed' but not")
    end
  end

  def test_common_fatal(t)
    c = Rgot::Common.new
    catch(:skip) {
      c.fatal(1, 2, 3)
      raise "never reach"
    }
    if /1 2 3/ !~ c.output
      t.error("expect output '1 2 3' got #{c.output.inspect}")
    end
    unless c.failed? && c.finished?
      t.error("expect status 'failed' and 'finished' but not")
    end
  end

  def test_common_fatalf(t)
    c = Rgot::Common.new
    catch(:skip) {
      c.fatalf("%d-%d-%d", 1, 2, 3)
      raise "never reach"
    }
    if /1-2-3/ !~ c.output
      t.error("expect output '1-2-3' got #{c.output.inspect}")
    end
    unless c.failed? && c.finished?
      t.error("expect status 'failed' and 'finished' but not")
    end
  end

  def test_common_skip(t)
    c = Rgot::Common.new
    catch(:skip) {
      c.skip(1, 2, 3)
      raise "never reach"
    }
    if /1 2 3/ !~ c.output
      t.error("expect output '1 2 3' got #{c.output.inspect}")
    end
    unless c.skipped? && c.finished?
      t.error("expect status 'skip' and 'finished' but not")
    end
  end

  def test_common_skipf(t)
    c = Rgot::Common.new
    catch(:skip) {
      c.skipf("%d-%d-%d", 1, 2, 3)
      raise "never reach"
    }
    if /1-2-3/ !~ c.output
      t.error("expect output '1-2-3' got #{c.output.inspect}")
    end
    unless c.skipped? && c.finished?
      t.error("expect status 'skip' and 'finished' but not")
    end
  end

  def test_pass(t)
    cmd = "rgot test/pass_test.rb -v"
    out = `#{cmd}`
    if /---\sPASS:\s.*/ !~ out
      t.error("expect PASS `#{cmd}` got #{out}")
    end
  end

  def test_fail(t)
    cmd = "rgot test/fail_test.rb -v"
    out = `#{cmd}`
    if /---\sFAIL:\s.*/ !~ out
      t.error("expect FAIL `#{cmd}` got #{out}")
    end
  end

  def test_fatal(t)
    cmd = "rgot test/fatal_test.rb -v"
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
    cmd = "rgot test/skip_test.rb -v"
    out = `#{cmd}`
    if /skip testing/ !~ out
      t.error("expect skip `#{cmd}` got #{out}")
    end
  end

  def test_timeout(t)
    cmd = "rgot test/timeout_test.rb -v --timeout 0.1"
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
    cmd = "rgot test/main_test.rb -v"
    out = `#{cmd}`
    if /start in main.*?run testing.*?end in main/m !~ out
      t.error("expect output start -> run -> end got '#{out}'")
    end
  end

  def test_main_method_return_code(t)
    code = Rgot::M.new(tests: [], benchmarks: [], examples: []).run
    unless Integer === code
      t.error("Rgot::M#run return expect to exit code, got #{code}")
    end
  end

  def test_benchmark(t)
    cmd = "rgot test/benchmark_test.rb --benchtime 0.4 --bench sum"
    out = `#{cmd}`
    if /benchmark_sum\s+\d+\s+\d+\s+ns\/op/ !~ out
      t.error("expect output benchmark report. got #{out}")
    end
  end

  def test_benchmark_parallel_procs(t)
    cmd = "rgot test/benchmark_test.rb --benchtime 0.1 --bench parallel --cpu=2,4"
    out = `#{cmd}`
    expect_out = <<-OUT.chomp
benchmark_parallel-2\\s+\\d+\\s+\\d+\\s+ns/op
benchmark_parallel-4\\s+\\d+\\s+\\d+\\s+ns/op
ok\\s+BenchmarkTest\\s+\\d+.\\d+s
OUT
    if /#{expect_out}/m !~ out
      t.error("expect match out. got #{out}")
    end
  end

  def test_benchmark_skip(t)
    cmd = "rgot test/benchmark_test.rb --bench skip"
    out = `#{cmd}`
    expect_out = <<-'OUT'
benchmark_skip\t\d\t\d\s+ns/op
---\s+BENCH:\s+benchmark_skip
\t.*?:\s+skip!
ok\tBenchmarkTest\t\d.\d+s
OUT
    if /#{expect_out}/ !~ out
      t.error("expect output not match")
    end
  end

  def test_benchmark_concurrent_threads(t)
    cmd = "rgot test/benchmark_test.rb --benchtime 0.01 --bench parallel --cpu=2,4 --thread=2,4"
    out = `#{cmd}`
    expect_out = <<-OUT.chomp
benchmark_parallel-2\\(2\\)\\s+\\d+\\s+\\d+\\s+ns/op
benchmark_parallel-2\\(4\\)\\s+\\d+\\s+\\d+\\s+ns/op
benchmark_parallel-4\\(2\\)\\s+\\d+\\s+\\d+\\s+ns/op
benchmark_parallel-4\\(4\\)\\s+\\d+\\s+\\d+\\s+ns/op
ok\\s+BenchmarkTest\\s+\\d+.\\d+s
OUT
    if /#{expect_out}/m !~ out
      t.error("expect match out. got #{out}")
    end
  end

  def test_benchmark_invalid_option(t)
    cmd = "rgot test/benchmark_test.rb --cpu=2,-1"
    out, err, status = Open3.capture3(cmd)
    if status.success?
      t.error("expect process not success `#{cmd}` got #{status}")
    end
    if /invalid value "-1" for --cpu \(Rgot::OptionError\)/ !~ err
      error_class = err.match(/\((.*?)\)/)[1]
      t.log(err)
      t.error("expect Rgot::OptionError got #{error_class}")
    end
    if /FAIL\s.*/ !~ out
      t.error("expect FAIL `#{cmd}` got #{out}")
    end
  end

  def test_example_pass(t)
    cmd = "rgot test/example_pass_test.rb"
    out = `#{cmd}`.chomp
    if /ok\s+ExamplePassTest/ !~ out
      t.error("want PASS got '#{out}'")
    end
  end

  def test_example_fail(t)
    cmd = "rgot test/example_fail_test.rb"
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
    cmd = "rgot -v test/foo"
    out = `#{cmd}`
    if /test_foo is ok.*?PASS/m !~ out
      t.error("want PASS got '#{out}'")
    end
  end

  def test_multi_dir_and_module(t)
    cmd = "rgot -v test/bar test/bar/baz"
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
        t.error("b.n expect over 0 since loop times")
      end
    }
    unless Rgot::BenchmarkResult === result
      t.error("expect instance of Rgot::BenchmarkResult got #{result.class}")
    end
  end

  def test_rgot_parallel_benchmark(t)
    r, w = IO.pipe
    Rgot.benchmark do |b|
      b.run_parallel do |pb|
        r.close
        w.write("t")
        unless pb.kind_of?(Rgot::PB)
          t.error("run_parallel block argument expect instance of Rgot::PB, got #{pb}")
        end
        unless ok = pb.next
          t.error("first Rgot::PB#next expect `true' got #{ok}")
        end
      end
    end
    w.close
    ret, err = go { r.read_nonblock(1) }
    if ret != "t" || err
      t.error("expect call block in run_parallel")
    end
  end

  def test_rgot_help(t)
    out = `rgot -h`
    expect_out = <<-HELP
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
HELP
    if out != expect_out
      t.error("rgot -h README.md and test should be update")
    end
  end

  private

  def go
    ret = nil
    err = nil
    begin
      ret = yield
    rescue => e
      err = e
    end
    [ret, err]
  end
end
