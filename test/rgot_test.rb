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

  def test_main_method(t)
    cmd = "bin/rgot test/main_test.rb -v"
    out = `#{cmd}`
    if /start in main.*?run testing.*?end in main/m !~ out
      t.error("expect output start -> run -> end got '#{out}'")
    end
  end

  def test_benchmark(b)
    cmd = "bin/rgot test/benchmark_test.rb --benchtime 1 --bench sum"
    out = `#{cmd}`
    if /benchmark_sum\s+\d+\s+\d+\.\d+\s+ns\/op/ !~ out
      t.error("expect output benchmark report. got #{out}")
    end
  end
end
