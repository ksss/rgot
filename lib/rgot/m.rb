require 'stringio'

module Rgot
  class M
    # Ruby-2.0.0 wants default value of keyword_argument
    def initialize(tests: [], benchmarks: [], examples: [], opts: {})
      @tests = tests
      @benchmarks = benchmarks
      @examples = examples
      @opts = opts
    end

    def run
      test_ok = false
      example_ok = false
      Timeout.timeout(@opts[:timeout].to_f) {
        test_ok = run_tests
        example_ok = run_examples
      }
      if !test_ok || !example_ok
        puts "FAIL"
        1
      else
        puts "PASS"
        0
      end
      run_benchmarks
    end

    private

    def run_tests
      ok = true
      @tests.each do |test|
        t = T.new(test.module, test.name.to_sym, @opts)
        if @opts[:verbose]
          puts "=== RUN #{test.name}"
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

    def run_examples
      ok = true
      @examples.each do |example|
        if @opts[:verbose]
          puts "=== RUN #{example.name}"
        end
        example.module.extend(example.module)
        method = example.module.instance_method(example.name).bind(example.module)
        out, err = capture do
          method.call
        end
        file = method.source_location[0]
        r = ExampleParser.new(File.read(file))
        r.parse
        e = r.examples.find{|e| e.name == example.name}
        if e && e.output.strip != out.strip
          ok = false
          puts "got:"
          puts out.strip
          puts "want:"
          puts e.output.strip
        end
      end
      ok
    end

    def capture
      orig_out, orig_err = $stdout, $stderr
      out, err = StringIO.new, StringIO.new
      $stdout, $stderr = out, err
      yield
      [out.string, err.string]
    ensure
      $stdout, $stderr = orig_out, orig_err
    end
  end
end
