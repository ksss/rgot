module FuzzingMultiTest
  def fuzz_multi1(f)
    f.add(5, "hello")
    f.fuzz do |t, i, s|
    end
  end

  def fuzz_multi2(f)
    f.add(5, "hello")
    f.fuzz do |t, i, s|
    end
  end
end
