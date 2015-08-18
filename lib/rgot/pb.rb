module Rgot
  class PB
    attr_accessor :bn

    # Ruby-2.0.0 wants default value of keyword_argument
    def initialize(bn: nil)
      raise ArgumentError, "missing keyword: bn" unless bn
      @bn = bn
    end

    def next
      @bn -= 1
      0 < @bn
    end
  end
end
