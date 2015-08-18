require 'stringio'

module Rgot
  class M
    # Ruby-2.0.0 wants default value of keyword_argument
    def initialize(tests: [], benchmarks: [], examples: [], opts: {})
      @tests = tests
      @benchmarks = benchmarks
      @examples = examples
      @opts = opts
      @cpu_list = @opts.fetch(:cpu, "1").split(',').map { |i|
        j = i.to_i
        if j == 0
          raise OptionError, "expect integer string, got #{i.inspect}"
        end
        j
      }
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
        return 1
      end
      puts "PASS" if @opts[:verbose]
      run_benchmarks
      0
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

        @cpu_list.each do |procs|
          opts = @opts.dup
          opts[:procs] = procs
          b = B.new(bench.module, bench.name.to_sym, opts)

          if 1 < procs
            printf "%s-%d\t", bench.name, procs
          else
            printf "%s\t", bench.name
          end
          result = b.run
          puts result
          if b.failed?
            ok = false
          end
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
