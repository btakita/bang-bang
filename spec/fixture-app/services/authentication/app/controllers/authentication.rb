FixtureApp::Controller.define_routes do
  def authentication_error_page; end
  get path(:authentication_error_page, "/authentication/error-page") do
    raise "An Error"
  end
end
