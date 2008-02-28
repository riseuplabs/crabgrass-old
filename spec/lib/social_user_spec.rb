require File.dirname(__FILE__) + '/../spec_helper'

describe "SocialUser" do
  
  before do
    @user = create_valid_user
    
  end

  it "should update groups array when changes happen" do
    @user.groups
    group = Group.create :name => 'hogwarts-academy'
    group.memberships.create :user => @user
    @user.group_ids.should == [ group.id ]
  end
  it "should update the all-groups array when changes happen" do
    #@user.group_ids
    #@user.all_group_ids
    #@user.groups
    @user.all_groups
    group = Group.create :name => 'hogwarts-academy'
    group.memberships.create :user => @user
    #@user.all_group_ids
    @user.all_group_ids.should == [ group.id ]
  end


end
