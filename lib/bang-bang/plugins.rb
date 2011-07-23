module BangBang
  module Plugins
    class Set
      attr_reader :config
      def initialize(config)
        @config = config
      end

      def on_init(&block)
        @on_init ||= []
        if block
          @on_init.push(block)
        else
          @on_init
        end
      end

      def init
        self.on_init.each do |block|
          block.call(config)
        end
      end
    end

    Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].each do |file|
      require file
    end
  end
end
