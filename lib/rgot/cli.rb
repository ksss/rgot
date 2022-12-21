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
      process_start(opts)
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

    def process_start(opts)
      code = 0
      testing_files.map do |testing_file|
        begin
          pid = fork do
            require testing_file

            modules = Object.constants.select { |c|
              next if c == :FileTest
              /.*Test\z/ =~ c
            }.map { |c|
              Object.const_get(c)
            }

            modules.each do |test_module|
              tests = []
              benchmarks = []
              examples = []
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

              duration = Rgot.now
              at_exit do
                template = "%s\t%s\t%.3fs"

                case $!
                when SystemExit
                  if $!.success?
                    # exit 0
                    puts sprintf(template, "ok  ", test_module, Rgot.now - duration)
                  else
                    # exit 1
                    puts "exit status #{$!.status}"
                    puts sprintf(template, "FAIL", test_module, Rgot.now - duration)
                  end
                when NilClass
                  # not raise, not exit
                else
                  # any exception
                  puts sprintf(template, "FAIL", test_module, Rgot.now - duration)
                end
              end
              m = Rgot::M.new(tests: tests, benchmarks: benchmarks, examples: examples, opts: opts)
              if main
                main.module.extend main.module
                main.module.instance_method(main.name).bind(main.module).call(m)
              else
                exit m.run
              end
            end
          end
        ensure
          _, status = Process.waitpid2(pid)
          unless status.success?
            code = 1
          end
        end
      end

      code
    end
  end
end
