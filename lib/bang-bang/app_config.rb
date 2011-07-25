module BangBang
  module AppConfig
    extend BangBang::Concern

    include ServiceConfig

    module ClassMethods
      attr_accessor :application_name, :stderr_dir, :stdout_dir

      def init(params={})
        self.application_name = params[:application_name] || raise(ArgumentError, "You must provide an :application_name param")
        params[:app_config] = self
        super
      end

      def stderr_logger
        @stderr_logger ||= Logger.new(stderr_dir)
      end

      def stdout_logger
        @stdout_logger ||= Logger.new(stdout_dir)
      end

      def stderr_dir
        "#{root_dir}/log/#{application_name}.#{rack_env}.stderr.log"
      end

      def stdout_dir
        "#{root_dir}/log/#{application_name}.#{rack_env}.stdout.log"
      end
    end
  end
end
