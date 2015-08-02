require "bundler/gem_tasks"

desc "test to rgot"
task :test do |t|
  target = "test/rgot_test.rb"
  ruby "bin/rgot -v #{target}"
end

task :default => [:test]
