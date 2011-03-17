module FixtureApp
  include ::TrueWeb

  def self.app
    @app ||= Rack::Builder.new do
      run ::FixtureApp::Controller
    end.to_app
  end

  class Controller < ::TrueWeb::Controller
  end

  class Views < ::TrueWeb::Views
  end

  class Routes < NamedRoutes::Routes
  end
end

FixtureApp.init(
  :controller => FixtureApp::Controller,
  :application_name => "fixture-app",
  :root_dir => File.dirname(__FILE__),
  :named_routes => FixtureApp::Routes,
  :views_class => FixtureApp::Views
)