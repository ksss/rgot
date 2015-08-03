module MainTest
  def test_main(m)
    puts "start in main"
    code = m.run
    puts "end in main"
    exit code
  end

  def test_some_1(t)
    puts "run testing"
  end
end
