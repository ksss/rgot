module Rgot
  class T < Common
    def initialize(test_module, name)
      super()
      @module = test_module
      @name = name
      @module.extend @module
    end

    def run
      catch(:skip) { call }
      finish!
      report
    rescue => e
      fail!
      report
      raise e
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
