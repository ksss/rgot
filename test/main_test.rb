module MainTest
  def test_main(m)
    puts "start in main"
    code = m.run
    puts "end in main"
    exit code
  end
end
