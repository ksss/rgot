module Rgot
  class T < Common
    def initialize(test_module, name, opts={})
      super()
      @test_module = test_module
      @name = name
      @opts = opts
    end

    def run
      begin
        @test_module.extend @test_module
        @test_module.instance_method(@name).bind(@test_module).call(self)
        finished!
      rescue => e
        fail!
        report
        raise e
      end
    end

    def report
      duration = Rgot.now - @start
      template = "--- %s: %s (%.5fs)\n%s"
      if failed?
        printf template, "FAIL", @name, duration, @output
      elsif @opts[:verbose]
        if skipped?
          printf template, "SKIP", @name, duration, @output
        else
          printf template, "PASS", @name, duration, @output
        end
      end
    end
  end
end
