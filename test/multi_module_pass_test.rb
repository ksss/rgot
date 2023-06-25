require 'open3'

module MonkeyPatch
  def test_call(t)
    raise("should not call")
  end
end

module MultiModuleTest
  def test_call(t)
    puts "multi module test ok"
  end
end
