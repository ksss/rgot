module Rgot
  require 'rgot/version'
  require 'rgot/common'
  require 'rgot/m'
  require 'rgot/t'
  require 'rgot/b'
  require 'rgot/pb'
  require 'rgot/benchmark_result'
  require 'rgot/example_parser'

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
    def now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def benchmark(opts_hash={}, &block)
      opts = B::Options.new
      opts_hash.each do |k, v|
        opts[k] = v
      end
      B.new(nil, nil, opts).run(&block)
    end

    def verbose?
      @chatty
    end
  end
end
