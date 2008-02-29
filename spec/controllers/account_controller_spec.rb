require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController do
  before do
    @user = users(:quentin)
  end

  describe "signin" do
    def act!
      post :login, :login => @user.login, :password => 'test'
    end
    def second_act!
      get :index
    end
    it "should redirect to me/dashboard" do
      act!
      response.should redirect_to( :controller => '/me', :action => 'index' )
    end

    it "should assign current user" do
      controller.should_receive(:current_user=).at_least(1).times.with(users(:quentin))
      act!
    end
    it "should add the user to the session" do
      act!
      session[:user].should == users(:quentin).id
    end

    it "should not redirect unless the login works" do
      second_act!
      response.should_not be_redirect
    end

    it "totally should redirect if the login works" do
      act!
      second_act!
      response.should redirect_to( me_url )
    end
  end



end
