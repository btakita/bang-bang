module TrueWeb
  module EnvMethods
    def development?
      rack_env == "development"
    end

    def rack_env
      ENV["RACK_ENV"]
    end

    extend self
  end
end
