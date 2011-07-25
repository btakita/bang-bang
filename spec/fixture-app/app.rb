module FixtureApp
  include ::BangBang::AppConfig

  def self.app
    @app ||= Rack::Builder.new do
      use Rack::Logger
      run ::FixtureApp::Controller
    end.to_app
  end

  class Controller < ::BangBang::Controller
    set :dump_errors, false
  end
  register_controller Controller

  class Views < ::BangBang::Views
  end

  class Routes < NamedRoutes::Routes
  end
end

FixtureApp.init(
  :application_name => "fixture-app",
  :root_dir => File.dirname(__FILE__),
  :named_routes => FixtureApp::Routes,
  :views_class => FixtureApp::Views
)

FixtureApp.register_service("#{File.dirname(__FILE__)}/services/authentication")
