require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  before do
    @page = Page.new :title => 'this is a very fine test page'
  end

  it "should make a friendly url from a nameized title and id" do
    @page.stubs(:id).returns('111')
    @page.friendly_url.should == 'this-is-a-very-fine-test-page+111'
  end

  it "should not consider the unique name taken if it's not" do
    @page.stubs(:name).returns('a page name')
    Page.stubs(:find).returns(nil)
    @page.name_taken?.should == false
  end

  it "should not consider the unique name taken if it's our own" do
    @page.stubs(:name).returns('a page name')
    Page.stubs(:find).returns(@page)
    @page.name_taken?.should == false
  end

  it "should consider name taken if another page has this name in the group namespace" do
    @page.stubs(:name).returns('a page name')
    Page.stubs(:find).returns(stub(:name => 'a page name'))
    @page.name_taken?.should == true
  end

  it "should allow a unique name to be nil" do
    @page.name = nil
    @page.should be_valid
  end

  it "should not allow a one letter unique name" do
    @page.name = "x"
    @page.should_not be_valid
  end

  it "should not allow unique names with over 40 word segments" do
    pending("doesn't seem to work, maybe my regex fu is weak?") do
      @page.name = "x" * 40 + "x"
      @page.should_not be_valid
      @page.should have(1).error_on(:name)
    end
    @page.name = "x-" * 39 + "x"
    @page.should be_valid
  end

  it "should not be valid if the name has changed to an existing name" do
    @page.stubs(:name_modified?).returns(true)
    @page.stubs(:name_taken?).returns(true)
    @page.should_not be_valid
    @page.should have(1).error_on(:name)
  end

  it "should resolve user participations when resolving" do
    up1 = up2 = mock()
    up1.expects(:update_attribute).with(:resolved, true)
    up2.expects(:update_attribute).with(:resolved, true)
    @page.stubs(:user_participations).returns([up1, up2])
    @page.expects(:update_attribute).with(:resolved, true)
    @page.resolve
  end

  it "should unresolve user participations when unresolving" do
    up1 = up2 = mock()
    up1.expects(:update_attribute).with(:resolved, false)
    up2.expects(:update_attribute).with(:resolved, false)
    @page.stubs(:user_participations).returns([up1, up2])
    @page.expects(:update_attribute).with(:resolved, false)
    @page.unresolve
  end
end
