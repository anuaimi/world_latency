require 'rake'

$:.unshift File.expand_path("../lib", __FILE__)
require "world_latency/version"

Gem::Specification.new do |s|
  s.name        = 'world_latency'
  s.version     = WorldLatency::VERSION
  s.date        = '2014-09-13'
  s.summary     = "calc network latency between various countries and server"
  s.description = "calc network latency between various countries and server"
  s.authors     = ["Athir Nuaimi"]
  s.email       = 'anuaimi@devfoundry.com'
  git_files     = `git ls-files`.split("\n") rescue ''
  s.files       = git_files
  s.executables = %w[world_latency]
  s.homepage    = 'http://rubygems.org/gems/world_latency'
  s.licenses     = %w[MIT]
end
