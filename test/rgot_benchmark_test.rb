require 'open3'

module RgotBenchmarkTest
  def test_benchmark(t)
    cmd = "rgot test/benchmark_test.rb --benchtime 0.4 --bench sum --cpu=1"
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
ok\\s+BenchmarkTest\\s+\\d+\\.\\d+s
OUT
    if /#{expect_out}/m !~ out
      t.error("expect match out. got #{out}")
    end
  end

  def test_benchmark_skip(t)
    cmd = "rgot test/benchmark_test.rb --bench skip --cpu=1"
    out = `#{cmd}`
    expect_out = <<-'OUT'
PASS
benchmark_skip\s+\d\s+\d\s+ns/op
---\s+BENCH:\s+benchmark_skip
\s+.*?:\s+skip!
ok\s+BenchmarkTest\s+\d.\d+s
OUT
    if /#{expect_out}/ !~ out
      t.errorf("expect output not match want:%s got:%s", expect_out, out)
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
      t.error("expect FAIL `#{cmd}` got \"#{out}\"")
    end
  end
end
