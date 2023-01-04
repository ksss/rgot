module FuzzingFailTest
  def fuzz_fail(f)
    f.add(5, "hello")
    f.fuzz do |t, i, s|
      t.error("fail in fuzz")
    end
  end
end
