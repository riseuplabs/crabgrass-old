require File.dirname(__FILE__) + '/../spec_helper'

describe ProfileController do

  it "should be able to edit your profile" do
    stub_login
    setup_profile {|p| p.should_receive(:entity).and_return(@user)}

    get :edit, :id => @profile.id
    response.should be_success
  end

  it "should not be able to edit someone else's profile" do
    stub_login
    setup_profile {|p| p.should_receive(:entity).and_return(mock_model(User)) }

    get :edit, :id => @profile.id
    response.should_not be_success
  end

  it "should allow group admin to edit group profile" do
    @group = mock_model(Group)
    stub_login {|u| u.should_receive(:member_of?).with(@group).and_return(true) }
    setup_profile do |p| 
      p.should_receive(:entity).and_return(@group)
    end

    get :edit, :id => @profile.id
    response.should be_success
  end

  it "should not allow non group admin to edit group profile" do
    @group = mock_model(Group)
    stub_login {|u| u.should_receive(:member_of?).with(@group).and_return(false) }
    setup_profile do |p|
      p.should_receive(:entity).and_return(@group)
    end

    get :edit, :id => @profile.id
    response.should_not be_success
  end

  protected
  def stub_login
    @user = mock_model(User)
    @user.stub!(:banner_style)
    @user.stub!(:time_zone)
    yield @user if block_given?
    controller.stub!(:current_user).and_return(@user)
    controller.stub!(:logged_in?).and_return(true)
  end

  def setup_profile
    @profile = mock_model(Profile::Profile)
    yield @profile if block_given?
    Profile::Profile.stub!(:find).and_return(@profile)
  end
end
