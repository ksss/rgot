module Rgot
  autoload :VERSION, 'rgot/version'
  autoload :Common, 'rgot/common'
  autoload :T, 'rgot/t'
  autoload :M, 'rgot/m'

  class InternalTestType < Struct.new(:module, :name)
  end

  class << self
    if "2.0.0" < RUBY_VERSION
      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    else
      def now
        Time.now
      end
    end
  end
end
