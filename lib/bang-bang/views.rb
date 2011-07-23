module BangBang
  class Views
    delegate :cookies, :current_user, :logged_in_user, :request, :response, :uris, :env, :params, :services, :to => :app_instance

    class << self
      def mustache(template_path, &definition)
        define_method_via_include(template_path, &definition)
        define_method_via_include(template_path) do |*args|
          Mustache.render(template_content(template_path), self.class.metadata(template_path).merge(super(*args)))
        end
      end

      def text(path, &definition)
        define_method_via_include(path, &definition)
      end

      def metadata(path)
        {
          'data-template' => path,
          'data-type' => "Template"
        }
      end

      def define_method_via_include(method_name, &definition)
        include(Module.new do
          define_method(method_name, &definition)
        end)
      end
    end

    attr_reader :app_instance

    def initialize(app_instance)
      @app_instance = app_instance
    end

    def app
      app_instance.class
    end

    def config
      app_instance.config
    end

    def [](path)
      unless respond_to?(path)
        config.services.find do |service|
          presenter_path = service.get_presenter_file_path(path)
          if presenter_path
            class_eval File.read(presenter_path), presenter_path, 1
          end
        end || begin
          self.class.mustache(path) {|*_| {}}
        end
      end

      o = lambda do |*args|
        send(path, *args)
      end

      def o.render(*args)
        self.call(*args)
      end
      o
    end

    def template_content(relative_path)
      File.read(full_path(relative_path))
    end

    protected

    def full_path(relative_path)
      services.each do |service|
        path = service.get_static_file_path(relative_path)
        return path if path
      end
      raise ArgumentError, "Path #{relative_path.inspect} does not exist in any of the services."
    end
  end
end
