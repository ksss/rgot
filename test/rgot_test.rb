require 'open3'

module RgotTest
  # This method should be running before testing
  def test_main(m)
    exit m.run
  end

  def test_pass(t)
    cmd = "bin/rgot test/pass_test.rb -v"
    out = `#{cmd}`
    if /---\sPASS:\s.*/ !~ out
      t.error("expect PASS `#{cmd}` got #{out}")
    end
  end

  def test_fail(t)
    cmd = "bin/rgot test/fail_test.rb -v"
    out = `#{cmd}`
    if /---\sFAIL:\s.*/ !~ out
      t.error("expect FAIL `#{cmd}` got #{out}")
    end
  end

  def test_fatal(t)
    cmd = "bin/rgot test/fatal_test.rb -v"
    out, err, status = Open3.capture3(cmd)
    if status.success?
      t.error("expect process not success `#{cmd}` got #{status}")
    end
    if /`sum': undefined method `\+' for nil:NilClass \(NoMethodError\)/ !~ err
      error_class = err.match(/\((.*?)\)/)[1]
      t.error("expect NoMethodError got #{error_class}")
    end
    if /---\sFAIL:\s.*/ !~ out
      t.error("expect FAIL `#{cmd}` got #{out}")
    end
  end
end
