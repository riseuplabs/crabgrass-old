require File.dirname(__FILE__) + '/../spec_helper'

describe PagesController do
  describe "when saving tags" do
    before do
      stub_login
      disable_filters
    end

    it "should call tag_with with some tags" do
      tags = "tag1 tag2 tag3"
      page = usable_page_stub 
      page.should_receive(:tag_with).with(tags)
      Page.stub!(:find_by_id).and_return(page)
      xhr :post, :tag, :id => '111', :tag_list => "tag1 tag2 tag3"
    end

    it "should call save on the Tag" do
      page = usable_page_stub
      Page.stub!(:find_by_id).and_return(page)
      page.should_receive(:save)
      xhr :post, :tag, :id => '111', :tag_list => "tag1 tag2 tag3"
    end

    it "should render the pages _tags partial" do
      page = usable_page_stub
      Page.stub!(:find_by_id).and_return(page)
      controller.expect_render(:partial => 'pages/tags') 
      xhr :post, :tag, :id => '111', :tag_list => "tag1 tag2 tag3"
    end
  end

  def disable_filters
    controller.stub!(:context)
    controller.stub!(:authorized?).and_return(true)
  end

  def usable_page_stub
    returning mock_model(Page) do |page|
      page.stub!(:participation_for_user)
      page.stub!(:tag_with)
      page.stub!(:save)
    end
  end

      
  def stub_login
    @user = mock_model(User)
    @user.stub!(:banner_style)
    @user.stub!(:time_zone)
    yield @user if block_given?
    controller.stub!(:current_user).and_return(@user)
    controller.stub!(:logged_in?).and_return(true)
  end
end
