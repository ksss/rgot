require 'stringio'
require 'etc'
require 'timeout'

module Rgot
  class M
    class Options < Struct.new(
      :bench,
      :benchtime,
      :timeout,
      :cpu,
      :thread,
    ); end

    def initialize(tests:, benchmarks:, examples:, opts: Options.new)
      cpu = opts.cpu || "#{Etc.respond_to?(:nprocessors) ? Etc.nprocessors : "1"}"
      @cpu_list = cpu.split(',').map { |i|
        j = i.to_i
        raise Rgot::OptionError, "invalid value #{i.inspect} for --cpu" unless 0 < j
        j
      }
      @thread_list = (opts.thread || "1").split(',').map { |i|
        j = i.to_i
        raise Rgot::OptionError, "invalid value #{i.inspect} for --thread" unless 0 < j
        j
      }
      @tests = tests
      @benchmarks = benchmarks
      @examples = examples
      @opts = opts
    end

    def run
      test_ok = false
      example_ok = false

      Timeout.timeout(@opts.timeout.to_f) do
        test_ok = run_tests
        example_ok = run_examples
      end
      if !test_ok || !example_ok
        puts "FAIL"
        return 1
      end
      puts "PASS"
      run_benchmarks
      0
    end

    private

    def run_tests
      ok = true
      @tests.each do |test|
        t = T.new(test.module, test.name.to_sym)
        if Rgot.verbose?
          puts "=== RUN   #{test.name}"
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
      return ok unless @opts.bench
      @benchmarks.each do |bench|
        next unless /#{@opts.bench}/ =~ bench.name

        @cpu_list.each do |procs|
          @thread_list.each do |threads|
            opts = B::Options.new
            opts.benchtime = @opts.benchtime
            opts.procs = procs
            opts.threads = threads
            b = B.new(bench.module, bench.name.to_sym, opts)

            benchname = bench.name.to_s
            benchname << "-#{procs}" if 1 < procs
            benchname << "(#{threads})" if 1 < threads
            print "#{benchname}\t"
            result = b.run
            if b.failed?
              ok = false
              next
            end
            puts result
            if 0 < b.output.length
              printf("--- BENCH: %s\n%s", benchname, b.output)
            end
          end
        end
      end
      ok
    end

    def run_examples
      ok = true
      @examples.each do |example|
        if Rgot.verbose?
          puts "=== RUN   #{example.name}"
        end

        start = Rgot.now
        example.module.extend(example.module)
        method = example.module.instance_method(example.name).bind(example.module)
        out, err = capture do
          method.call
        end
        file = method.source_location[0]
        r = ExampleParser.new(File.read(file))
        r.parse
        e = r.examples.find { |e| e.name == example.name }

        duration = Rgot.now - start
        if e && e.output.strip != out.strip
          printf("--- FAIL: %s (%.2fs)\n", e.name, duration)
          ok = false
          puts "got:"
          puts out.strip
          puts "want:"
          puts e.output.strip
        elsif Rgot.verbose?
          printf("--- PASS: %s (%.2fs)\n", e.name, duration)
        end
      end
      ok
    end

    def capture
      raise LocalJumpError, "no block given" unless block_given?

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
