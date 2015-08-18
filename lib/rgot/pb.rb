module Rgot
  class PB
    attr_accessor :bn
    def initialize(bn:)
      @bn = bn
    end

    def next
      @bn -= 1
      0 < @bn
    end
  end
end
