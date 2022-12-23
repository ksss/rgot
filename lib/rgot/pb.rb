# frozen_string_literal: true

module Rgot
  class PB
    attr_accessor :bn

    def initialize(bn:)
      @bn = bn
    end

    def next
      (0 < @bn).tap { @bn -= 1 }
    end
  end
end
