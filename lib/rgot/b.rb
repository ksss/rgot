module Rgot
  class B < Common
    Options = Struct.new(
      :procs,
      :threads,
      :benchtime,
    )

    attr_accessor :n
    def initialize(benchmark_module, name, opts=Options.new)
      super()
      @n = 1
      @module = benchmark_module
      @name = name
      @opts = opts
      @timer_on = false
      @duration = 0
      @module.extend @module if @module
    end

    def start_timer
      if !@timer_on
        @start = Rgot.now
        @timer_on = true
      end
    end

    def stop_timer
      if @timer_on
        @duration += Rgot.now - @start
        @timer_on = false
      end
    end

    def reset_timer
      if @timer_on
        @start = Rgot.now
      end
      @duration = 0
    end

    def run(&block)
      n = 1
      benchtime = (@opts.benchtime || 1).to_f
      catch(:skip) do
        run_n(n.to_i, block)
        while !failed? && @duration < benchtime && @n < 1e9
          if @duration < (benchtime / 100.0)
            @n *= 100
          elsif @duration < (benchtime / 10.0)
            @n *= 10
          elsif @duration < (benchtime / 5.0)
            @n *= 5
          elsif @duration < (benchtime / 2.0)
            @n *= 2
          else
            if @n.to_i == 1
              break
            end
            @n *= 1.2
          end
          run_n(@n.to_i, block)
        end
      end

      BenchmarkResult.new(n: @n, t: @duration)
    end

    def run_parallel
      raise LocalJumpError, "no block given" unless block_given?

      procs = (@opts.procs || 1)
      threads = (@opts.threads || 1)

      procs.times do
        fork do
          Array.new(threads) {
            Thread.new {
              yield PB.new(bn: @n)
            }.tap { |t| t.abort_on_exception = true }
          }.each(&:join)
        end
      end
      @n *= procs * threads
      Process.waitall
    end

    private

    def run_n(n, block=nil)
      GC.start
      @n = n
      reset_timer
      start_timer
      if block
        block.call(self)
      else
        bench_method = @module.instance_method(@name).bind(@module)
        if bench_method.arity == 0
          path, line = bench_method.source_location
          self.skip "#{path}:#{line} `#{bench_method.name}' is not running. It's a benchmark method name, But not have argument"
        else
          bench_method.call(self)
        end
      end
      stop_timer
    end
  end
end
