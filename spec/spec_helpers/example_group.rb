RSpec::Core::ExampleGroup.class_eval do
  include Capybara

  def app
    FixtureApp::Controller
  end

  def uris
    @uris ||= FixtureApp::Routes.instance
  end
  alias_method :named_routes, :uris

  def views
    @views ||= begin
      app_instance = Capybara.app.allocate
      app_instance.send(:initialize)
      app_instance.session_data = session_data
      ::FixtureApp::Views.new(app_instance)
    end
  end

  [
    :request, :last_request, :response, :last_response, :follow_redirect!,
    :rack_mock_session
  ].each do |method_name|
    class_eval((<<-RUBY), __FILE__, __LINE__+1)
    def #{method_name}(*args, &block)
      page.driver.#{method_name}(*args, &block)
    end
    RUBY
  end

  [:get, :put, :post, :delete].each do |method_name|
    class_eval((<<-RUBY), __FILE__, __LINE__+1)
    def #{method_name}(*args, &block)
      (res = page.driver.#{method_name}(*args, &block)).tap do
        puts res.errors if res.status == 500
      end
    end
    RUBY
  end

  def current_path
    Addressable::URI.parse(current_url).path
  end

end
