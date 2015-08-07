module Rgot
  require 'rgot/version'
  require 'rgot/common'
  require 'rgot/m'
  require 'rgot/t'
  require 'rgot/b'
  require 'rgot/ripper_example'

  class OptionError < StandardError
  end

  class InternalTest < Struct.new(:module, :name)
  end

  class InternalBenchmark < Struct.new(:module, :name)
  end

  class InternalExample < Struct.new(:module, :name)
  end

  class ExampleOutput < Struct.new(:name, :output)
  end

  class << self
    if "2.0.0" < RUBY_VERSION
      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    else
      def now
        Time.now
      end
    end
  end
end
