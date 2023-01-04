module RgotFuzzingTest
  def test_fuzzing_pass(t)
    cmd = "rgot test/fuzzing_pass_test.rb --fuzz . --fuzztime 0.1"
    out = `#{cmd}`

    expect_out = <<-OUT.chomp
\\Afuzz: elapsed: 0s, execs: \\d+ \\(0/sec\\), new interesting: \\d+ \\(total: \\d+\\)
fuzz: elapsed: 0s, execs: \\d+ \\(0/sec\\), new interesting: \\d+ \\(total: \\d+\\)
PASS
ok\\s+FuzzingPassTest\\s+0\\.\\d{3}s
OUT
    unless /#{expect_out}/m.match?(out)
      t.error("expect output fuzz report. got #{out}")
    end
  end

  def test_fuzzing_pass_verbose(t)
    cmd = "rgot test/fuzzing_pass_test.rb -v --fuzz . --fuzztime 0.1"
    out = `#{cmd}`

    expect_out = <<-OUT.chomp
\\A===\\s+FUZZ\\s+fuzz_pass
fuzz: elapsed: 0s, execs: \\d+ \\(0/sec\\), new interesting: \\d+ \\(total: \\d+\\)
fuzz: elapsed: 0s, execs: \\d+ \\(0/sec\\), new interesting: \\d+ \\(total: \\d+\\)
---\\s+.*PASS.*:\\s+fuzz_pass\\s+\\(0\\.\\d{2}s\\)
PASS
ok\\s+FuzzingPassTest\\s+0\\.\\d{3}s
OUT
    unless /#{expect_out}/m.match?(out)
      t.error("expect output fuzz report. got #{out}")
    end
  end

  def test_fuzzing_fail(t)
    cmd = "rgot test/fuzzing_fail_test.rb --fuzz . --fuzztime 0.1"
    out = `#{cmd}`

    expect_out = <<-OUT.chomp
\\A---\\s+.*FAIL.*:\\s+fuzz_fail\\s+\\(0.\\d{2}s\\)
FAIL
exit\\sstatus\\s1
FAIL\\s+FuzzingFailTest\\s+0\.\\d{3}s
OUT
    unless /#{expect_out}/m.match?(out)
      t.error("expect output fuzz report. got #{out}")
    end
  end

  def test_fuzzing_fail_verbose(t)
    cmd = "rgot test/fuzzing_fail_test.rb -v --fuzz . --fuzztime 0.1"
    out = `#{cmd}`

    expect_out = <<-OUT.chomp
\\A===\\s+FUZZ\\s+fuzz_fail
---\\s+.*FAIL.*:\\s+fuzz_fail\\s+\\(0.\\d{2}s\\)
FAIL
exit\\sstatus\\s1
FAIL\\s+FuzzingFailTest\\s+0\.\\d{3}s
OUT
    unless /#{expect_out}/m.match?(out)
      t.error("expect output fuzz report. got #{out}")
    end
  end

  def test_fuzzing_multi(t)
    cmd = "rgot test/fuzzing_multi_test.rb -v --fuzz . --fuzztime 0.1"
    out = `#{cmd}`

    expect_out = <<-OUT.chomp
rgot: will not fuzz, --fuzz matches more than one fuzz test: \\[:fuzz_multi2, :fuzz_multi1\\]
FAIL
exit status 1
FAIL\\s+FuzzingMultiTest\\s+0\.\\d{3}s
OUT
    unless /#{expect_out}/m.match?(out)
      t.error("expect output fuzz report. got #{out}")
    end
  end
end
