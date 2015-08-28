require 'thread'

module Rgot
  class Common
    attr_accessor :output

    def initialize
      @output = ""
      @failed = false
      @skipped = false
      @finished = false
      @start = Rgot.now
      @mutex = Mutex.new
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
      @mutex.synchronize { @failed = true }
    end

    def skip!
      @mutex.synchronize { @skipped = true }
    end

    def finish!
      @mutex.synchronize { @finished = true }
    end

    def log(*args)
      internal_log(args.map(&:to_s).join(' '))
    end

    def logf(*args)
      internal_log(sprintf(*args))
    end

    def error(*args)
      internal_log(args.map(&:to_s).join(' '))
      fail!
    end

    def errorf(*args)
      internal_log(sprintf(*args))
      fail!
    end

    def fatal(*args)
      internal_log(args.map(&:to_s).join(' '))
      fail_now
    end

    def fatalf(*args)
      internal_log(sprintf(*args))
      fail_now
    end

    def skip(*args)
      internal_log(args.map(&:to_s).join(' '))
      skip_now
    end

    def skipf(*args)
      internal_log(sprintf(*args))
      skip_now
    end

    def skip_now
      skip!
      finish!
      throw :skip
    end

    def fail_now
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
      @mutex.synchronize { @output << decorate(msg) }
    end
  end
end
