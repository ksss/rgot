module Rgot
  class B < Common
    attr_accessor :n
    def initialize(benchmark_module, name, opts)
      super()
      @n = 1
      @module = benchmark_module
      @name = name
      @opts = opts
      @benchtime = @opts.fetch(:benchtime, 1).to_f
      @timer_on = false
      @start = Rgot.now
      @duration = 0
      @module.extend @module
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

    def run
      n = 1
      a = Rgot.now
      run_n(n)
      while !failed? && @duration < @benchtime && @n < 1e9
        if @duration < (@benchtime / 100.0)
          n *= 100
        elsif @duration < (@benchtime / 10.0)
          n *= 10
        elsif @duration < (@benchtime / 5.0)
          n *= 5
        elsif @duration < (@benchtime / 2.0)
          n *= 2
        else
          n *= 1.2
        end
        run_n(n)
      end
    end

    def report
      printf("%s\t%d\t%.3f ns/op\n", @name, @n, @duration / @n * 1_000_000_000)
    end

    private

    def run_n(n)
      GC.start
      i = 0
      @n = n
      reset_timer
      start_timer
      call
      stop_timer
    end

    def call
      @module.instance_method(@name).bind(@module).call(self)
    end
  end
end
