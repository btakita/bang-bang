# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'true-web/version'

Gem::Specification.new do |s|
  s.name        = "true-web"
  s.version     = ::TrueWeb::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian Takita"]
  s.email       = ["btakita@truecar.com"]
  s.homepage    = "https://github.com/TrueCar/true-web"
  s.summary     = %q{A lightweight Sinatra web MVC stack}
  s.description = %q{A lightweight Sinatra web MVC stack}

  s.required_rubygems_version = ">= 1.3.6"

  # Man files are required because they are ignored by git
  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths      = ["lib"]
end
