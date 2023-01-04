module FuzzingPassTest
  def fuzz_pass(f)
    unless f.kind_of?(Rgot::F)
      f.error("unexpected type #{f.class} - #{f}")
    end
    f.add(100, "hello")
    f.fuzz do |t, i, s|
      unless t.kind_of?(Rgot::T)
        t.error("unexpected type #{t.class} - #{t}")
      end
      unless i.kind_of?(Integer)
        t.error("unexpected type #{i.class} - #{i}")
      end
      unless s.kind_of?(String)
        t.error("unexpected type #{s.class} - #{s}")
      end
      # loop
    end
  end
end
