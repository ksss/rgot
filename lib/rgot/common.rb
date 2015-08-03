module Rgot
  class Common
    def initialize
      @output = ""
      @failed = false
      @skipped = false
      @finished = false
      @start = Rgot.now
    end

    def failed?
      @failed
    end

    def skipped?
      @skipped
    end

    def finished?
      @finished
    end

    def fail!
      @failed = true
    end

    def skip!
      @skipped = true
    end

    def finish!
      @finished = true
    end

    def log(*args)
      internal_log(sprintf(*args))
    end

    def skip(*args)
      internal_log(sprintf(*args))
      skip_now!
    end

    def skip_now
      skip!
      finish!
      throw :skip
    end

    def error(*args)
      internal_log(sprintf(*args))
      fail!
    end

    def fatal(msg)
      internal_log(msg)
      fail_now!
    end

    def fail_now!
      fail!
      finish!
      throw :skip
    end

    private

    def decorate(str)
      c = caller[2] # internal_log -> other log -> running method
      path = c.sub(/:.*/, '')
      line = c.match(/:(\d+?):/)[1]
      relative_path = Pathname.new(path).relative_path_from(Pathname.new(Dir.pwd)).to_s
      "\t#{relative_path}:#{line}: #{str}\n"
    end

    def internal_log(msg)
      @output << decorate(msg)
    end
  end
end
