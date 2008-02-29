require File.dirname(__FILE__) + '/../spec_helper'

describe UserObserver do

  it "is called when the user saves" do
    @observer = UserObserver.instance
    @observer.should_receive :after_save
    @user = create_valid_user
  end

  describe "forgot password" do
    it "calls the UserMailer to send a forgot password notice" do
      @user = create_valid_user
      @user.forgot_password
      UserMailer.should_receive :deliver_forgot_password
      @user.save!
    end

    it "doesnt call forgot password normally" do
      @user = create_valid_user
      UserMailer.should_not_receive :deliver_forgot_password
      @user.save!
    end
  
  end

  describe "reset password sends email" do

    it "doesnt call reset password normally" do
      @user = create_valid_user
      UserMailer.should_not_receive :deliver_reset_password
      @user.save!
    end

    it "sends reset_password after the pw is reset" do
      @user = create_valid_user
      @user.reset_password
      UserMailer.should_receive :deliver_reset_password
      @user.save!
    end
  end

end
