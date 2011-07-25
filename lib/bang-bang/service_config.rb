module BangBang
  module ServiceConfig
    extend Concern

    module ClassMethods
      attr_accessor :app_config, :root_dir
      attr_writer :named_routes, :views_class

      include ::BangBang::EnvMethods

      def init(params={})
        self.app_config = params[:app_config]
        self.root_dir = params[:root_dir]
        self.named_routes = params[:named_routes]
        self.views_class = params[:views_class]

        plugins.init
      end

      def named_routes
        @named_routes || (app_config && app_config.named_routes) || nil
      end
      alias_method :uris, :named_routes
      alias_method :uris=, :named_routes=

      def views_class
        @views_class || (app_config && app_config.views_class) || nil
      end

      def register_controller(controller)
        controller.config = self
      end

      def register_service(path, &block)
        unless service_dirs.include?(path)
          service = Service.new(self, path)
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

      def remove_generated_files
        Dir["#{root_dir}/**/public/**/*.generated"].each do |generated_path|
          FileUtils.rm_f(File.join(File.dirname(generated_path), File.basename(generated_path, ".generated")))
          FileUtils.rm_f(generated_path)
        end
      end
    end
  end
end