# frozen_string_literal: true

module Rgot
  require 'rgot/version'
  require 'rgot/common'
  require 'rgot/m'
  require 'rgot/t'
  require 'rgot/b'
  require 'rgot/pb'
  require 'rgot/benchmark_result'
  require 'rgot/example_parser'

  OptionError = Class.new(StandardError)
  InternalTest = Struct.new(:module, :name)
  InternalBenchmark = Struct.new(:module, :name)
  InternalExample = Struct.new(:module, :name)
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
