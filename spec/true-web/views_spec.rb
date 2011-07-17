require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module TrueWeb
  describe Views do
    describe "#[]" do
      it "returns an object with a render method, which invokes the given method name" do
        view = TrueWeb::Views.new(Object.new)
        mock(view, "true_car_makes")

        view["true_car_makes"].render
      end

      describe "lazily created method" do
        context "when the presenter file exists" do
          it "evals the presenter file (which is responsible for adding the method)" do
            authentication_path = "#{FixtureApp.root_dir}/services/authentication"
            service = Service.new(authentication_path).init
            app_instance = Object.new
            stub(app_instance).services {[service]}
            stub(app_instance).config {FixtureApp}
            views = Class.new(TrueWeb::Views).new(app_instance)

            html = views["/authentication/index.html.ms"].call("param1 value")
            html.should include("param1 value")
            doc = Nokogiri::HTML(html)
            doc.at(".child-div").should be_present
          end
        end

        context "when the presenter file does not exist" do
          it "lazily creates a method that render the mustache template for the given path" do
            app_instance = Object.new
            app_instance.class.send(:define_method, :config) do
              FixtureApp
            end
            views = Class.new(TrueWeb::Views).new(app_instance)

            views.respond_to?("/user/pagelets/i-dont-exist").should be_false
            views["/user/pagelets/i-dont-exist"]
            views.respond_to?("/user/pagelets/i-dont-exist").should be_true
          end
        end
      end
    end
  end
end
