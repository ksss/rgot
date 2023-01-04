# frozen_string_literal: true

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
      :fuzz,
      :fuzztime,
    ); end

    def initialize(tests:, benchmarks:, examples:, fuzz_targets: nil, test_module: nil, opts: Options.new)
      unless fuzz_targets
        raise "Require `fuzz_targets` keyword" if Gem::Version.new("2.0") <= Gem::Version.new(Rgot::VERSION)
        warn "`Rgot::M#initialize` will require the `fuzz_targets` keyword in the next major version."
      end
      unless test_module
        raise "Require `test_module` keyword" if Gem::Version.new("2.0") <= Gem::Version.new(Rgot::VERSION)
        warn "`Rgot::M#initialize` will require the `test_module` keyword in the next major version."
      end

      @tests = tests
      @benchmarks = benchmarks
      @examples = examples
      @fuzz_targets = fuzz_targets || []
      @test_module = test_module
      @opts = opts

      @cpu_list = []
      @thread_list = []
      @fs = @fuzz_targets.map do |fuzz_target|
        F.new(
          fuzz_target: fuzz_target,
          opts: F::Options.new(
            fuzz: opts.fuzz,
            fuzztime: opts.fuzztime,
          )
        )
      end
    end

    def run
      duration = Rgot.now
      test_ok = false
      fuzz_targets_ok = false
      example_ok = false

      if @tests.empty? && @benchmarks.empty? && @examples.empty? && @fuzz_targets.empty?
        warn "rgot: warning: no tests to run"
      end

      begin
        parse_option
      rescue Rgot::OptionError
        puts sprintf("%s\t%s\t%.3fs", "FAIL", @test_module, Rgot.now - duration)
        raise
      end

      Timeout.timeout(@opts.timeout.to_f) do
        test_ok = run_tests
        fuzz_targets_ok = run_fuzz_tests
        example_ok = run_examples
      end

      if !test_ok || !example_ok || !fuzz_targets_ok
        puts "FAIL"
        puts "exit status 1"
        puts sprintf("%s\t%s\t%.3fs", "FAIL", @test_module, Rgot.now - duration)
        return 1
      end

      if !run_fuzzing()
        puts "FAIL"
        puts "exit status 1"
        puts sprintf("%s\t%s\t%.3fs", "FAIL", @test_module, Rgot.now - duration)
        return 1
      end

      puts "PASS"
      run_benchmarks
      puts sprintf("%s\t%s\t%.3fs", "ok  ", @test_module, Rgot.now - duration)

      0
    end

    private

    def parse_option
      cpu = @opts.cpu || (Etc.respond_to?(:nprocessors) ? Etc.nprocessors : '1').to_s
      @cpu_list = cpu.split(',').map { |i|
        j = i.to_i
        raise Rgot::OptionError, "invalid value #{i.inspect} for --cpu" unless 0 < j
        j
      }

      @thread_list = (@opts.thread || "1").split(',').map { |i|
        j = i.to_i
        raise Rgot::OptionError, "invalid value #{i.inspect} for --thread" unless 0 < j
        j
      }
    end

    def run_tests
      ok = true
      @tests.each do |test|
        t = T.new(test.module, test.name.to_sym)
        if Rgot.verbose?
          puts "=== RUN   #{test.name}"
        end
        t.run
        ok = ok && !t.failed?
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

    def run_fuzz_tests
      ok = true
      @fs.each do |f|
        if Rgot.verbose?
          if f.fuzz?
            puts "=== FUZZ  #{f.name}"
          else
            puts "=== RUN   #{f.name}"
          end
        end
        f.run_testing
        ok = ok && !f.failed?
      end
      ok
    end

    def run_fuzzing
      if @fuzz_targets.empty? || @opts.fuzz.nil?
        return true
      end

      fuzzing_fs = @fs.select(&:fuzz?)

      if fuzzing_fs.empty?
        puts "rgot: warning: no fuzz tests to fuzz"
        return true
      end

      if fuzzing_fs.length > 1
        names = fuzzing_fs.map(&:name)
        puts "rgot: will not fuzz, --fuzz matches more than one fuzz test: #{names.inspect}"
        return false
      end

      ok = true

      fuzzing_fs.each do |f|
        f.run_fuzzing
        ok = ok && !f.failed?
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
        out, _ = capture do
          method.call
        end
        file = method.source_location&.[](0) or raise("bug")
        example_parser = ExampleParser.new(File.read(file))
        example_parser.parse
        e = example_parser.examples.find { |er| er.name == example.name } or raise("bug")

        duration = Rgot.now - start
        if e.output.strip != out.strip
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
