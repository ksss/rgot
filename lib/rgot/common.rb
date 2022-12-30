# frozen_string_literal: true

require 'thread'
require 'pathname'

module Rgot
  class Common
    # @dynamic output, output=
    attr_accessor :output

    def initialize
      @output = "".dup
      @failed = false
      @skipped = false
      @finished = false
      @start = Rgot.now
      @mutex = Thread::Mutex.new
    end

    def failed?
      @mutex.synchronize { @failed }
    end

    def skipped?
      @mutex.synchronize { @skipped }
    end

    def finished?
      @mutex.synchronize { @finished }
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
      nil
    end

    def logf(*args)
      internal_log(sprintf(*args))
      nil
    end

    def error(*args)
      internal_log(args.map(&:to_s).join(' '))
      fail!
      nil
    end

    def errorf(*args)
      internal_log(sprintf(*args))
      fail!
      nil
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
      # internal_log -> synchronize -> internal_log -> other log -> running method
      c = caller[4]
      path = c.sub(/:.*/, '')
      line = c.match(/:(\d+?):/)&.[](1)
      relative_path = Pathname.new(path).relative_path_from(Pathname.new(Dir.pwd)).to_s
      # Every line is indented at least 4 spaces.
      "    #{relative_path}:#{line}: #{str}\n"
    end

    def internal_log(msg)
      @mutex.synchronize { @output << decorate(msg) }
    end
  end
end
