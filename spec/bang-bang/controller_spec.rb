require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module BangBang
  describe Controller do
    describe "GET /authentication/error-page" do
      context "when there is not a rack.logger" do
        it "responds with a 500" do
          any_instance_of(FixtureApp::Controller) do |controller|
            stub.proxy(controller).env do |env|
              env.delete("rack.logger")
              env
            end
          end
          get uris.authentication_error_page

          response.status.should == 500
        end
      end

      context "when there is a rack.logger" do
        it "responds with a 500 and logs the message" do
          message = nil
          any_instance_of(Logger) do |l|
            stub(l).error(is_a(String)) do |*args|
              message = args.first
            end
          end
          get uris.authentication_error_page

          response.status.should == 500
          message.should include("An Error")
        end
      end
    end
  end
end