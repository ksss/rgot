module Rgot
  class PB
    attr_accessor :bn

    # Ruby-2.0.0 wants default value of keyword_argument
    def initialize(bn: nil)
      raise ArgumentError, "missing keyword: bn" unless bn
      @bn = bn
    end

    def next
      (0 < @bn).tap { @bn -= 1 }
    end
  end
end
