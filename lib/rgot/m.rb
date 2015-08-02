module Rgot
  class M
    def initialize(tests:, benchmarks:, opts:)
      @tests = tests
      @benchmarks = benchmarks
      @opts = opts
    end

    def run
      test_ok = run_tests
      benchmark_ok = run_benchmarks
      if !test_ok || !benchmark_ok
        puts "FAIL"
        1
      else
        puts "PASS"
        0
      end
    end

    private

    def run_tests
      ok = true
      @tests.each do |test|
        t = T.new(test.module, test.name.to_sym, @opts)
        if @opts[:verbose]
          puts "=== RUN #{test.name}\n"
        end
        t.run
        t.report
        if t.failed?
          ok = false
        end
      end
      ok
    end

    def run_benchmarks
      ok = true
      return ok unless @opts[:bench]
      @benchmarks.each do |bench|
        next unless /#{@opts[:bench]}/ =~ bench.name

        b = B.new(bench.module, bench.name.to_sym, @opts)
        b.run
        b.report
        if b.failed?
          ok = false
        end
      end
      ok
    end
  end
end
