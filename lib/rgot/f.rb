module Rgot
  # def fuzz_foo(f)
  #   f.add(5, "hello")
  #   f.fuzz do |t, i, s|
  #     ...
  #   end
  class F < Common
    class Options
      # @dynamic fuzz, fuzz=, fuzztime, fuzztime=
      attr_accessor :fuzz
      attr_accessor :fuzztime
      def initialize(fuzz:, fuzztime:)
        @fuzz = fuzz
        @fuzztime = fuzztime
      end
    end

    class CorpusEntry
      # @dynamic values, values=, is_seed, is_seed=, path, path=
      attr_accessor :values
      attr_accessor :is_seed
      attr_accessor :path
      def initialize(values:, is_seed:, path:)
        @values = values
        @is_seed = is_seed
        @path = path
      end

      def mutate_values
        @values.map do |value|
          if generator = SUPPORTED_TYPES[value.class]
            generator.call(value)
          else
            raise "unsupported type #{value.class}"
          end
        end
      end
    end

    class Coordinator
      # @dynamic count, count=, interesting_count, interesting_count=
      attr_accessor :count
      attr_accessor :interesting_count

      def initialize(warmup_input_count:)
        @warmup_input_count = warmup_input_count
        @before_cov = 0
        @start_time = Rgot.now
        @count = 0
        @interesting_count = 0
        @count_last_log = 0
        @time_last_log = 0.0
      end

      def start_logger
        Thread.new do
          loop do
            log_stats
            sleep 3
          end
        end
      end

      def diff_coverage
        current_cov = Coverage.peek_result.sum do |path, hash|
          hash.map do |_, covs|
            covs.length
          end.sum
        end
        (current_cov - @before_cov).tap { @before_cov = current_cov }
      end

      def log_stats
        rate = Float(count - @count_last_log) / (Rgot.now - @time_last_log)
        total = @warmup_input_count + interesting_count
        printf "fuzz: elapsed: %ds, execs: %d (%d/sec), new interesting: %d (total: %d)\n",
          elapsed, count, rate, interesting_count, total

        duration = Rgot.now - @time_last_log
        @count_last_log = count
        @time_last_log = Rgot.now
      end

      private

      def elapsed
        (Rgot.now - @start_time).round
      end
    end

    SUPPORTED_TYPES = {
      TrueClass => ->(v) { [true, false].sample },
      FalseClass => ->(v) { [true, false].sample },
      Integer => ->(v) { Random.rand(v) },
      Float => ->(v) { Random.rand(v) },
      String => ->(v) { Random.bytes(v.length) },
    }

    # @dynamic name
    attr_reader :name

    def initialize(fuzz_target:, opts:)
      super()
      @opts = opts
      @fuzz_target = fuzz_target
      @fuzz_block = nil
      @module = fuzz_target.module
      @name = fuzz_target.name
      @corpus = []
    end

    # TODO: DRY with T
    def run
      catch(:skip) { call }
      finish!
    rescue => e
      fail!
      raise e
    end

    def run_testing
      run
      report if !fuzz? || failed?
    end

    def run_fuzzing
      return unless fuzz?
      raise("must call after #fuzz") unless @fuzz_block

      coordinator = Coordinator.new(
        warmup_input_count: @corpus.length
      )
      coordinator.start_logger

      t = T.new(@fuzz_target.module, @fuzz_target.name)

      begin
        Timeout.timeout(@opts.fuzztime.to_f) do
          loop do
            @corpus.each do |entry|
              values = entry.mutate_values

              @fuzz_block.call(t, *values)

              if 0 < coordinator.diff_coverage
                coordinator.interesting_count += 1
              end
              coordinator.count += 1
              fail! if t.failed?
            end
          end
        end
      rescue Timeout::Error, Interrupt
        coordinator.log_stats
      end

      report
    end

    def add(*args)
      args.each do |arg|
        unless SUPPORTED_TYPES.key?(arg.class)
          raise "unsupported type to Add #{arg.class}"
        end
      end
      entry = CorpusEntry.new(
        values: args.dup,
        is_seed: true,
        path: "seed##{@corpus.length}"
      )
      @corpus.push(entry)
    end

    def fuzz(&block)
      unless block
        raise LocalJumpError, "must set block"
      end
      unless 2 <= block.arity
        raise "fuzz target must receive at least two arguments"
      end

      t = T.new(@fuzz_target.module, @fuzz_target.name)

      @corpus.each do |entry|
        unless entry.values.length == (block.arity - 1)
          raise "wrong number of values in corpus entry: #{entry.values.length}, want #{block.arity - 1}"
        end
        block.call(t, *entry.values.dup)
        fail! if t.failed?
      end

      @fuzz_block = block

      nil
    end

    def fuzz?
      return false unless @opts.fuzz
      return false unless Regexp.new(@opts.fuzz.to_s).match?(@fuzz_target.name)
      true
    end

    def report
      puts @output if Rgot.verbose? && !@output.empty?
      duration = Rgot.now - @start
      template = "--- \e[%sm%s\e[m: %s (%.2fs)\n"
      if failed?
        printf template, [41, 1].join(';'), "FAIL", @name, duration
      elsif Rgot.verbose?
        if skipped?
          printf template, [44, 1].join(';'), "SKIP", @name, duration
        else
          printf template, [42, 1].join(';'), "PASS", @name, duration
        end
      end
    end

    private

    def call
      test_method = @module.instance_method(@name).bind(@module)
      if test_method.arity == 0
        path, line = test_method.source_location
        warn "#{path}:#{line} `#{test_method.name}' is not running. It's a testing method name, But not have argument"
      else
        test_method.call(self)
      end
    end
  end
end
