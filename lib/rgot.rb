# frozen_string_literal: true

module Rgot
  autoload :VERSION, 'rgot/version'
  autoload :Common, 'rgot/common'
  autoload :M, 'rgot/m'
  autoload :T, 'rgot/t'
  autoload :B, 'rgot/b'
  autoload :PB, 'rgot/pb'
  autoload :BenchmarkResult, 'rgot/benchmark_result'
  autoload :F, 'rgot/f'
  autoload :ExampleParser, 'rgot/example_parser'

  OptionError = Class.new(StandardError)
  InternalTest = Struct.new(:module, :name)
  InternalBenchmark = Struct.new(:module, :name)
  InternalExample = Struct.new(:module, :name)
  InternalFuzzTarget = Struct.new(:module, :name)
  ExampleOutput = Struct.new(:name, :output)

  class << self
    def now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def benchmark(opts_hash = {}, &block)
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
