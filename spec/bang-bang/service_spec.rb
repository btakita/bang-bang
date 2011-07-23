require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module BangBang
  describe Service do
    describe "#get_static_file_path" do
      context "when the service has a file matching the given url" do
        it "returns the file path of the static file base on the Service's prefix + file path" do
          authentication_path = "#{FixtureApp.root_dir}/services/authentication"
          service = Service.new(authentication_path).init
          service.url_prefix.should == "/authentication"
          service.get_static_file_path("/authentication/javascripts/foo.js").should ==
            File.join(authentication_path, "/public/javascripts/foo.js")
        end
      end

      context "when the service does not have a file matching the given url" do
        it "returns nil" do
          authentication_path = "#{FixtureApp.root_dir}/services/authentication"
          service = Service.new(authentication_path).init
          service.get_static_file_path("i-dont-exist").should be_nil
        end
      end
    end

    describe "#templates_hash" do
      it "returns a hash of all of the template files" do
        authentication_path = "#{FixtureApp.root_dir}/services/authentication"
        service = Service.new(authentication_path).init

        hash = service.templates_hash
        hash["/authentication/index.html.ms"].should == File.read(File.join(service.templates_dir, "index.html.ms"))
      end
    end
  end
end
