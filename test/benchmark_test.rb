require_relative './sample'

module BenchmarkTest
  def benchmark_sum(b)
    i = 0
    s = Sample.new
    while i < b.n
      s.sum(10, 2)
      i += 1
    end
  end
end
