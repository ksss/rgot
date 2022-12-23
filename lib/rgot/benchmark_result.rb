# frozen_string_literal: true

module Rgot
  class BenchmarkResult
    def initialize(n:, t:)
      @n = n
      @t = t
    end

    def to_s
      sprintf("%d\t%d ns/op", @n, @t / @n * 1_000_000_000)
    end
  end
end
