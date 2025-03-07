require 'open3'

module RgotTest
  # This method should be running before testing
  def test_main(m)
    m.run
  end

  def test_pass(t)
    cmd = "rgot test/pass_test.rb -v"
    out = `#{cmd}`
    unless /PASS/ =~ out
      t.error("expect PASS `#{cmd}` got #{out}")
    end
    unless $?.success?
      t.error("expect exit status 0, but got #{$?}")
    end
  end

  def test_fail(t)
    cmd = "rgot test/fail_test.rb -v"
    out = `#{cmd}`
    unless /FAIL/ =~ out
      t.error("expect FAIL `#{cmd}` got #{out}")
    end
    unless !$?.success?
      t.error("expect exit status fail, but not")
    end
  end

  def test_fatal(t)
    cmd = "rgot test/fatal_test.rb -v"
    out, err, status = Open3.capture3(cmd)
    if status.success?
      t.error("expect process not success `#{cmd}` got #{status}")
    end
    if /\(NoMethodError\)/ !~ err
      error_class = err.match(/\((.*?)\)/)[1]
      t.log(err)
      t.error("expect NoMethodError got #{error_class}")
    end
    unless /FAIL/ =~ out
      t.error("expect FAIL `#{cmd}` got #{out}")
    end
  end

  def test_skip(t)
    cmd = "rgot test/skip_test.rb -v"
    out = `#{cmd}`
    unless /SKIP/ =~ out
      t.error("expect skip `#{cmd}` got #{out}")
    end
  end

  def test_timeout(t)
    cmd = "rgot test/timeout_test.rb -v --timeout 0.1"
    out, err, status = Open3.capture3(cmd)
    if status.success?
      t.error("expect process not success `#{cmd}` got #{status}")
    end
    if /\(Timeout::Error\)/ !~ err
      error_class = err.match(/\((.*?)\)/)[1]
      t.log(err)
      t.error("expect Timeout::Error got #{error_class}")
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

  def test_multi_module_pass(t)
    cmd = "rgot test/multi_module_pass_test.rb -v"
    out = `#{cmd}`
    if /multi module test ok/ !~ out
      t.error("expect output 'multi module test ok', but got '#{out}'")
    end
  end

  def test_multi_module_fail(t)
    cmd = "rgot test/multi_module_fail_test.rb -v"
    out, err, status = Open3.capture3(cmd)
    unless !status.success?
      t.error("should be fail, but success")
    end
    unless err.include?("*Test module should be one for each file")
      t.error("expect output '*Test module should be one for each file', but got '#{err}'")
    end
  end

  def test_main_method_return_code(t)
    code = Rgot::M.new(tests: [], benchmarks: [], examples: [], fuzz_targets: [], test_module: RgotTest).run
    unless Integer === code
      t.error("Rgot::M#run return expect to exit code, got #{code}")
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
    start = Time.now
    last_n = 0
    result = Rgot.benchmark(benchtime: 0.2) { |b|
      unless Rgot::B === b
        t.error("expect instance of Rgot::B got #{b.class}")
      end
      unless 0 < b.n
        t.error("b.n expect over 0 since loop times")
      end
      sleep(b.n * 0.01)
      last_n = b.n
    }
    duration = (Time.now - start)
    unless 0.2 < duration
      t.error("too fast benchmark running time expect=0.2s got=#{duration}s")
    end
    unless duration < 5
      t.error("too slow benchmark running time expect=5s got=#{duration}s")
    end
    unless 5 <= last_n
      t.error("too few times last_n=#{last_n}")
    end
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
        --fuzz [regexp]              run the fuzz test matching `regexp`
        --fuzztime [sec]             time to spend fuzzing; default is to run indefinitely
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
