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
  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    attr_accessor :controller, :application_name, :named_routes, :stderr_dir, :stdout_dir, :root_dir, :views_class
    alias_method :uris, :named_routes
    delegate :define_routes, :to => :controller

    include ::BangBang::EnvMethods

    def init(params={})
      self.controller        = params[:controller] || raise(ArgumentError, "You must provide an :controller param")
      self.application_name   = params[:application_name] || raise(ArgumentError, "You must provide an :application_name param")
      self.root_dir          = params[:root_dir] || raise(ArgumentError, "You must provide a :root_dir param")
      self.named_routes       = params[:named_routes] || raise(ArgumentError, "You must provide a :named_routes param")
      self.views_class        = params[:views_class] || raise(ArgumentError, "You must provide a :views_class param")
      self.controller.config = self

      plugins.init
    end

    def app
      @app ||= Rack::Builder.new do
        run controller
      end.to_app
    end

    def register_service(path, &block)
      unless service_dirs.include?(path)
        service = Service.new(path)
        services << service
        service.init(&block)
      end
    end

    def service_dirs
      services.map do |service|
        service.root_dir
      end
    end

    def services
      @services ||= []
    end

    def services_by_url_prefix
      services.group_by do |service|
        service.url_prefix
      end
    end

    def services_by_root_dir
      services.inject({}) do |memo, service|
        memo[service.root_dir] = service
        memo
      end
    end

    def stderr_logger
      @stderr_logger ||= Logger.new(stderr_dir)
    end

    def stdout_logger
      @stdout_logger ||= Logger.new(stdout_dir)
    end

    def plugins
      @plugins ||= ::BangBang::Plugins::Set.new(self)
    end

    def lib_dir
      File.join(root_dir, "lib")
    end

    def stylesheets_dirs
      service_subdirectory_dirs "app/stylesheets"
    end

    def vendor_dir
      File.join(root_dir, "vendor")
    end

    def services_dir
      File.join(root_dir, "services")
    end

    def service_subdirectory_dirs(relative_directory)
      service_dirs.flatten.map do |service_path|
        full_path = File.join(service_path, relative_directory)
        full_path if File.directory?(full_path)
      end.compact
    end

    def stderr_dir
      "#{root_dir}/log/#{application_name}.#{rack_env}.stderr.log"
    end

    def stdout_dir
      "#{root_dir}/log/#{application_name}.#{rack_env}.stdout.log"
    end

    def remove_generated_files
      Dir["#{root_dir}/**/public/**/*.generated"].each do |generated_path|
        FileUtils.rm_f(File.join(File.dirname(generated_path), File.basename(generated_path, ".generated")))
        FileUtils.rm_f(generated_path)
      end
    end
  end
end

require "#{dir}/bang-bang/controller"
require "#{dir}/bang-bang/service"
require "#{dir}/bang-bang/views"
require "#{dir}/bang-bang/plugins"
