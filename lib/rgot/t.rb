module Rgot
  class T < Common
    class Options < Struct.new(
      :verbose
    ); end

    def initialize(test_module, name, opts=Options.new)
      super()
      @module = test_module
      @name = name
      @opts = opts
      @module.extend @module
    end

    def run
      begin
        catch(:skip) { call }
        finish!
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
      elsif @opts.verbose
        if skipped?
          printf template, "SKIP", @name, duration, @output
        else
          printf template, "PASS", @name, duration, @output
        end
      end
    end

    def call
      @module.instance_method(@name).bind(@module).call(self)
    end
  end
end
