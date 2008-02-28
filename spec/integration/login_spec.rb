require File.dirname(__FILE__) + '/../spec_helper.rb'
describe 'Login with webrat' do

  describe 'create contact' do
    before(:all) do
      @webrat = ActionController::Integration::Session.new
    end

    before(:each) do
      @webrat.reset!
      login_test_user
    end

  
    it "can log in" do
      @webrat.reset!
      login_test_user
      @webrat.response.body.should match(/logged in/)
    end
    
    it "shows the dashboard" do
      @webrat.visits "/me/dashboard"
      @webrat.response.should be_success
    end
    it "shows the dashboard and the inbox" do
      @webrat.visits "/me/dashboard"
      @webrat.visits "/me/inbox"
      @webrat.response.should be_success
    end


  end

  def login_test_user
    @webrat.visits "/account/login"
    @webrat.fills_in "login", :with => "jackie"
    @webrat.fills_in "password", :with => "test"
    @webrat.clicks_button "Log in"
  end
end


