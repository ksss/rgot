module Rgot
  class BenchmarkResult
    # Ruby-2.0.0 wants default value of keyword_argument
    def initialize(n: nil, t: nil)
      raise ArgumentError, "missing keyword: n" unless n
      raise ArgumentError, "missing keyword: t" unless t
      @n = n
      @t = t
    end

    def to_s
      sprintf("%d\t%d ns/op", @n, @t / @n * 1_000_000_000)
    end
  end
end
