module RgotExampleTest
  def test_example_pass(t)
    cmd = "rgot test/example_pass_test.rb"
    out = `#{cmd}`.chomp
    if /ok\s+ExamplePassTest/ !~ out
      t.error("want PASS got '#{out}'")
    end
  end

  def test_example_fail(t)
    cmd = "rgot test/example_fail_test.rb"
    out = `#{cmd}`
    expect_out = <<-OUT.chomp
--- FAIL: example_singleline (\d+.\d+s)
got:
ok go
want:
ng back
--- FAIL: example_multiline (\d+.\d+s)
got:
Hello
I'm example
want:
bye
I'm fail
FAIL
FAIL	ExamplePassTest
OUT
    if Regexp.new(expect_out) =~ out
      t.error("\n--- expect:\n#{expect_out}\n--- got:\n#{out}\n")
    end
  end
end
