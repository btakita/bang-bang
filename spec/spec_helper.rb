require "rubygems"
dir = File.dirname(__FILE__)

$LOAD_PATH.unshift(File.expand_path("#{dir}/../lib"))

require "rack/test"

require "true-web"
require "#{dir}/fixture-app/app"

gem "nokogiri"
gem "rack-test", "0.5.6"
gem "capybara", "0.4.0"
gem "honkster-addressable", "2.2.3"

require "rack/session/abstract/id"
require "rack/test"
require "capybara"
require "capybara/dsl"
require "nokogiri"
require "addressable/uri"

ARGV.push("-b")
unless ARGV.include?("--format") || ARGV.include?("-f")
  ARGV.push("--format", "nested")
end

require 'rspec'
require 'rspec/autorun'
require 'rr'
require 'webmock/rspec'

ENV["RACK_ENV"] = "test"

Dir["#{File.dirname(__FILE__)}/spec_helpers/**/*.rb"].each do |file|
  require file
end

RSpec.configure do |configuration|
  configuration.mock_with :rr
  configuration.filter_run :focus => true
  configuration.run_all_when_everything_filtered = true
  configuration.before do
    Capybara.reset!

    FixtureApp.views_class = FixtureApp::Views
  end
end

Capybara.app = FixtureApp.app
