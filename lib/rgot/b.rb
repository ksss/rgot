module Rgot
  class B < Common
    attr_accessor :n
    def initialize(benchmark_module, name, opts={})
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
      benchtime = @opts.fetch(:benchtime, 1).to_f
      run_n(n, block)
      while !failed? && @duration < benchtime && @n < 1e9
        if @duration < (benchtime / 100.0)
          n *= 100
        elsif @duration < (benchtime / 10.0)
          n *= 10
        elsif @duration < (benchtime / 5.0)
          n *= 5
        elsif @duration < (benchtime / 2.0)
          n *= 2
        else
          n *= 1.2
        end
        run_n(n, block)
      end

      BenchmarkResult.new(n: @n, t: @duration)
    end

    private

    def run_n(n, block=nil)
      GC.start
      i = 0
      @n = n
      reset_timer
      start_timer
      if block
        block.call(self)
      else
        @module.instance_method(@name).bind(@module).call(self)
      end
      stop_timer
    end
  end
end
