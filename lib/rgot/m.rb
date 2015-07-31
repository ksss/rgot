module Rgot
  class M
    def initialize(cases, opts)
      @cases = cases
      @opts = opts
    end

    def run
      test_ok = run_tests
      if !test_ok
        puts "FAIL"
        1
      else
        puts "PASS"
        0
      end
    end

    private

    def run_tests
      ok = true
      @cases.each do |c|
        test_module, m = c
        t = Rgot::T.new(test_module, m.to_sym, @opts)
        if @opts[:verbose]
          puts "=== RUN #{m}\n"
        end
        t.run
        t.report
        if t.failed?
          ok = false
        end
      end
      ok
    end
  end
end
