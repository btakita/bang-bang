dir = File.dirname(__FILE__)
Dir[File.expand_path("#{dir}/../vendor/*/lib")].each do |path|
  $LOAD_PATH.unshift(path)
end
require 'sinatra/base'
require 'mustache'
require 'yajl'
require 'active_support/all'
require 'addressable/uri'
require "named-routes"
require "superhash"
require "#{dir}/bang-bang/version"
require "#{dir}/bang-bang/env_methods"

module BangBang
end

require "#{dir}/bang-bang/concern"
require "#{dir}/bang-bang/service_config"
require "#{dir}/bang-bang/app_config"
require "#{dir}/bang-bang/controller"
require "#{dir}/bang-bang/service"
require "#{dir}/bang-bang/views"
require "#{dir}/bang-bang/plugins"
