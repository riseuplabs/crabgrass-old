require File.dirname(__FILE__) + '/../spec_helper'

describe User, "when forgetting a password" do

  before do
    @user = create_valid_user
  end

  it "should find a user by email address" do
    User.find_for_forget("aviary@birdcage.com").should be_an_instance_of(User)
  end

  it "should create a password reset code" do
    @user.__send__ :make_password_reset_code
    @user.password_reset_code.should_not be_nil
  end

  it "should be have a general forgot password method" do
    @user.forgot_password
    @user.recently_forgot_password?.should be_true 
  end

  it "should allow resetting the password" do
    @user.forgot_password
    @user.reset_password
    @user.password_reset_code.should be_nil
  end

end
