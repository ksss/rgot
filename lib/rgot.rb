module Rgot
  autoload :VERSION, 'rgot/version'
  autoload :Common, 'rgot/common'
  autoload :T, 'rgot/t'
  autoload :M, 'rgot/m'

  class InternalTestType < Struct.new(:module, :name)
  end

  class << self
    def now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
