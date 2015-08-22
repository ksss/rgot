require_relative './sample'

module BenchmarkTest
  def fibo(n)
    if n < 2
      n
    else
      fibo(n - 1) + fibo(n - 2)
    end
  end

  def benchmark_sum(b)
    i = 0
    s = Sample.new
    while i < b.n
      s.sum(10, 2)
      i += 1
    end
  end

  def benchmark_parallel(b)
    b.run_parallel do |pb|
      while pb.next
        fibo(27)
      end
    end
  end

  def benchmark_skip(b)
    b.skip "skip!"
    raise "never reach!"
  end
end
