# frozen_string_literal: true

require 'ripper'

module Rgot
  class ExampleParser < Ripper

    # @dynamic examples, examples=
    attr_accessor :examples

    def initialize(code)
      super
      @examples = []
      @in_def = false
      @has_output = false
      @output = "".dup
    end

    def on_def(method, args, body)
      @examples << ExampleOutput.new(method.to_sym, @output.dup)
      @output.clear
      @has_output = false
      @in_def = false
    end

    def on_comment(a)
      if @in_def
        if @has_output
          @output << a.sub(/\A#\s*/, '')
        else
          if /#\s*Output:\s*(.*?\n)/ =~ a
            text = $1
            if 0 < text.length || text[0] != "\n"
              @output << text
            end
            @has_output = true
          end
        end
      end
    end

    def on_kw(a)
      case a
      when "def"
        @in_def = true
      when "end"
        @in_def = false
      end
    end
  end
end
