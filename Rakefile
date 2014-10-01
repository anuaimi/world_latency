require 'bundler/setup'
require File.dirname(__FILE__) + '/lib/world_latency'

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  WorldLatency::VERSION
end

def gemspec_file
  "#{name}.gemspec"
end

def gem_file
  "#{name}-#{version}.gem"
end

GEM_NAME = "#{name}"

#task :default => :test
#task :travis  => ['test', 'test:travis']

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/#{name}.rb"
end

desc "Build world_latency-#{version}.gem"
task :build do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end
task :gem => :build
