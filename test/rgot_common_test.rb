module RgotTest
  def test_common_log(t)
    c = Rgot::Common.new
    c.log(1, 2, 3)
    if /1 2 3/ !~ c.output
      t.error("expect output '1 2 3' got #{c.output.inspect}")
    end
  end

  def test_common_logf(t)
    c = Rgot::Common.new
    c.logf("%d-%d-%d", 1, 2, 3)
    if /1-2-3/ !~ c.output
      t.error("expect output '1-2-3' got #{c.output.inspect}")
    end
  end

  def test_common_error(t)
    c = Rgot::Common.new
    c.error(1, 2, 3)
    if /1 2 3/ !~ c.output
      t.error("expect output '1 2 3' got #{c.output.inspect}")
    end
    unless c.failed?
      t.error("expect status 'failed' but not")
    end
  end

  def test_common_errorf(t)
    c = Rgot::Common.new
    c.errorf("%d-%d-%d", 1, 2, 3)
    if /1-2-3/ !~ c.output
      t.error("expect output '1-2-3' got #{c.output.inspect}")
    end
    unless c.failed?
      t.error("expect status 'failed' but not")
    end
  end

  def test_common_fatal(t)
    c = Rgot::Common.new
    catch(:skip) {
      c.fatal(1, 2, 3)
      raise "never reach"
    }
    if /1 2 3/ !~ c.output
      t.error("expect output '1 2 3' got #{c.output.inspect}")
    end
    unless c.failed? && c.finished?
      t.error("expect status 'failed' and 'finished' but not")
    end
  end

  def test_common_fatalf(t)
    c = Rgot::Common.new
    catch(:skip) {
      c.fatalf("%d-%d-%d", 1, 2, 3)
      raise "never reach"
    }
    if /1-2-3/ !~ c.output
      t.error("expect output '1-2-3' got #{c.output.inspect}")
    end
    unless c.failed? && c.finished?
      t.error("expect status 'failed' and 'finished' but not")
    end
  end

  def test_common_skip(t)
    c = Rgot::Common.new
    catch(:skip) {
      c.skip(1, 2, 3)
      raise "never reach"
    }
    if /1 2 3/ !~ c.output
      t.error("expect output '1 2 3' got #{c.output.inspect}")
    end
    unless c.skipped? && c.finished?
      t.error("expect status 'skip' and 'finished' but not")
    end
  end

  def test_common_skipf(t)
    c = Rgot::Common.new
    catch(:skip) {
      c.skipf("%d-%d-%d", 1, 2, 3)
      raise "never reach"
    }
    if /1-2-3/ !~ c.output
      t.error("expect output '1-2-3' got #{c.output.inspect}")
    end
    unless c.skipped? && c.finished?
      t.error("expect status 'skip' and 'finished' but not")
    end
  end
end
