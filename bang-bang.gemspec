# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bang-bang/version'

Gem::Specification.new do |s|
  s.name        = "bang-bang"
  s.version     = ::BangBang::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian Takita"]
  s.email       = ["btakita@truecar.com"]
  s.homepage    = "https://github.com/TrueCar/bang-bang"
  s.summary     = %q{A lightweight Sinatra web MVC stack}
  s.description = %q{A lightweight Sinatra web MVC stack}

  s.required_rubygems_version = ">= 1.3.6"

  # Man files are required because they are ignored by git
  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths      = ["lib"]

  s.add_dependency "activesupport", ">=2.0.0"
  s.add_dependency "honkster-addressable", ">=2.2.3"
  s.add_dependency "mustache"
  s.add_dependency "named-routes", ">=0.2.7"
  s.add_dependency "sinatra", ">=1.2.0"
  s.add_dependency "yajl-ruby", ">=0.8.1"

  s.add_development_dependency "capybara", ">=0.4.0"
  s.add_development_dependency "i18n", ">=0.5.0"
  s.add_development_dependency "rack-test", ">=0.5.6"
  s.add_development_dependency "rr", ">=1.0.2"
  s.add_development_dependency "rspec", ">=2.2.0"
  s.add_development_dependency "ruby-debug19", ">=0.11.6"
  s.add_development_dependency "webmock", ">=1.6.2"
end
