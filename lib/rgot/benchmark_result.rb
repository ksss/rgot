module Rgot
  class BenchmarkResult
    def initialize(n:, t:)
      @n = n
      @t = t
    end

    def to_s
      sprintf("%d\t%.3f ns/op", @n, @t / @n * 1_000_000_000)
    end
  end
end
