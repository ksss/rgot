require "bundler/gem_tasks"

desc "test to rgot"
task :test do |t|
  targets = [
    "test/rgot_common_test.rb",
    "test/rgot_test.rb",
    "test/rgot_benchmark_test.rb",
    "test/rgot_example_test.rb",
    "test/rgot_fuzzing_test.rb",
  ]
  ruby "bin/rgot -v #{targets.join(' ')}"
end

task :default => [:test]
