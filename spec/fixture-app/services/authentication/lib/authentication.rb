module Authentication
  include BangBang::ServiceConfig

  class Controller < ::BangBang::Controller
    set :dump_errors, false
  end
  register_controller Controller

  class Views < ::BangBang::Views
  end

  class Routes < NamedRoutes::Routes
  end

  init(
    :views => Views,
    :routes => Routes,
    :root_dir => File.expand_path("#{File.dirname(__FILE__)}/.."),
    :named_routes => Routes,
    :views_class => Views
  )
end
