# frozen_string_literal: true

require 'optparse'

require_relative '../rgot'

module Rgot
  class Cli
    def initialize(argv)
      @argv = argv
    end

    def run
      opts = Rgot::M::Options.new
      parse_option(opts)
      main_process(opts)
    end

    private

    def parse_option(opts)
      require_paths = []
      parser = OptionParser.new do |o|
        o.on '-v', '--verbose', "log all tests" do |arg|
          Rgot.class_eval { @chatty = arg }
        end
        o.on '--version', "show Rgot version" do |arg|
          puts "rgot #{Rgot::VERSION} (ruby #{RUBY_VERSION})"
          exit 0
        end
        o.on '--bench [regexp]', "benchmark" do |arg|
          unless arg
            raise Rgot::OptionError, "missing argument for flag --bench"
          end
          opts.bench = arg
        end
        o.on '--benchtime [sec]', "benchmark running time" do |arg|
          opts.benchtime = arg
        end
        o.on '--timeout [sec]', "set timeout sec to testing" do |arg|
          opts.timeout = arg
        end
        o.on '--cpu [count,...]', "set cpu counts of comma split" do |arg|
          opts.cpu = arg
        end
        o.on '--thread [count,...]', "set thread counts of comma split" do |arg|
          opts.thread = arg
        end
        o.on '--require [path]', "load some code before running" do |arg|
          require_paths << arg
        end
        o.on '--load-path [path]', "Specify $LOAD_PATH directory" do |arg|
          $LOAD_PATH.unshift(arg)
        end
        o.on '--fuzz [regexp]', "run the fuzz test matching `regexp`" do |arg|
          unless arg
            raise Rgot::OptionError, "missing argument for flag --fuzz"
          end
          opts.fuzz = arg
        end
        o.on '--fuzztime [sec]', "time to spend fuzzing; default is to run indefinitely" do |arg|
          opts.fuzztime = arg
        end
      end
      parser.parse!(@argv)

      require_paths.each do |path|
        require path
      end
    end

    def testing_files
      if @argv.empty?
        Dir.glob("./**/*_test.rb")
      else
        @argv.flat_map do |target|
          if File.file?(target)
            File.expand_path(target)
          elsif File.directory?(target)
            Dir.glob("./#{target}/**/*_test.rb")
          else
            warn "#{target} is not file or directory"
          end
        end.compact
      end
    end

    def main_process(opts)
      code = 0

      testing_files.each do |testing_file|
        result = child_process(opts, testing_file)
        unless result == 0
          code = 1
        end
      end

      code
    end

    def child_process(opts, testing_file)
      node = RubyVM::AbstractSyntaxTree.parse_file(testing_file).children[2]
      test_module_name = find_toplevel_name(node)

      if opts.fuzz
        # fuzzing observes changes in coverage.
        require 'coverage'
        Coverage.start(oneshot_lines: true)
      end
      load testing_file

      test_module = Object.const_get(test_module_name)
      tests = []
      benchmarks = []
      examples = []
      fuzz_targets = []
      main = nil
      methods = test_module.public_instance_methods
      methods.grep(/\Atest_/).each do |m|
        if m == :test_main && main.nil?
          main = Rgot::InternalTest.new(test_module, m)
        else
          tests << Rgot::InternalTest.new(test_module, m)
        end
      end

      methods.grep(/\Abenchmark_/).each do |m|
        benchmarks << Rgot::InternalBenchmark.new(test_module, m)
      end

      methods.grep(/\Aexample_?/).each do |m|
        examples << Rgot::InternalExample.new(test_module, m)
      end

      methods.grep(/\Afuzz_/).each do |m|
        fuzz_targets << Rgot::InternalFuzzTarget.new(test_module, m)
      end

      m = Rgot::M.new(
        test_module: test_module,
        tests: tests,
        benchmarks: benchmarks,
        examples: examples,
        fuzz_targets: fuzz_targets,
        opts: opts
      )
      if main
        main.module.extend main.module
        main.module.instance_method(:test_main).bind(main.module).call(m)
      else
        m.run
      end
    end

    def find_toplevel_name(node)
      case node.type
      when :MODULE
        find_toplevel_name(node.children.first)
      when :CONST, :COLON3
        node.children.first
      when :COLON2
        case node.children
        in [nil, sym]
          # module Foo
          sym
        in [namespace, sym]
          # module Foo::Bar
          find_toplevel_name(namespace)
        end
      when :BLOCK
        module_node = node.children.find { |c| c.type == :MODULE }
        unless module_node
          raise "no module found"
        end
        find_toplevel_name(module_node)
      else
        raise node.type.to_s
      end
    end
  end
end
