module BangBang
  class Controller < Sinatra::Base
    set :raise_errors, false
    set :show_exceptions, false

    class_inheritable_accessor :config
    extend(Module.new do
      def uris
        config.uris
      end

      def views_class
        config.views_class
      end

      def path(*args, &block)
        uris.path(*args, &block)
      end

      def services
        config.services
      end
    end)

    TEMPLATE_TYPE_NAME = "Template"

    set :logging, true
    set :static, true
    attr_reader :helper, :views

    error(403) do
      "<div>Sorry, the page you're trying to access is private.</div>"
    end

    error(404) do
      "<div>Sorry, we could not find the page you were looking for.</div>"
    end

    error(500) do
      env["rack.exception"] = env["sinatra.error"]
      if env["rack.logger"]
        env["rack.logger"].error "#{env["sinatra.error"].message}\n#{env["sinatra.error"].backtrace.join("\n\t")}"
      end
      "<div>Oops, an error occurred.</div>"
    end

    before do
      @views = self.class.views_class.new(self)
    end

    def services
      self.class.services
    end

    def uris
      self.class.uris
    end

    def view(path, *args)
      views[path].render(*args)
    end

    def static!
      nil
    end

    module Controllers
      module ClassMethods
        def define_routes(&route_definition)
          controller = Class.new(self)
          controller.class_eval(&route_definition)
          controllers << controller
        end

        def controllers
          @controllers ||= []
        end

        def pagelet_access_resources(pagelet_json_path, paglet_asset_json_path, html_path=nil)
          if html_path
            get html_path do
              send(html_path)
            end
          end

          get pagelet_json_path do
            response['Content-Type'] = 'application/json'
            send(paglet_asset_json_path).merge(
              html_path ? {
                :html => send(html_path)
              } : {}
            ).to_json
          end

          get paglet_asset_json_path do
            response['Content-Type'] = 'application/json'
            send(paglet_asset_json_path).to_json
          end
        end
      end

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # Overrode call! to speed up routing to subresources.
      def call!(env)
        self.class.controllers.each do |controller|
          request = ::Sinatra::Request.new(env)
          routes = controller.routes[request.request_method] || []
          path = unescape(request.path_info)
          routes.each do |pattern, keys, conditions, block|
            if pattern.match(path)
              subapp_instance = controller.allocate
              subapp_instance.send(:initialize, nil)
              response = subapp_instance.call(env)
              return response if response[0] != 404
            end
          end
        end
        super
      end
    end
    include Controllers
  end
end
