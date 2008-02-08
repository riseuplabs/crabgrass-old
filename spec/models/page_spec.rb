require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  before do
    @page = Page.new :title => 'this is a very fine test page'
  end

  it "should make a friendly url from a nameized title and id" do
    @page.stub!(:id).and_return('111')
    @page.friendly_url.should == 'this-is-a-very-fine-test-page+111'
  end

  it "should not consider the unique name taken if it's not" do
    @page.stub!(:name).and_return('a page name')
    Page.stub!(:find).and_return(nil)
    @page.name_taken?.should == false
  end

  it "should not consider the unique name taken if it's our own" do
    @page.stub!(:name).and_return('a page name')
    Page.stub!(:find).and_return(@page)
    @page.name_taken?.should == false
  end

  it "should consider name taken if another page has this name in the group namespace" do
    @page.stub!(:name).and_return('a page name')
    Page.stub!(:find).and_return(stub(:name => 'a page name'))
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
    @page.stub!(:name_modified?).and_return(true)
    @page.stub!(:name_taken?).and_return(true)
    @page.should_not be_valid
    @page.should have(1).error_on(:name)
  end

  it "should resolve user participations when resolving" do
    up1 = mock_model( UserParticipation, :resolved= => nil, :save => nil )
    up2 = mock_model( UserParticipation, :resolved= => nil, :save => nil )
    up1.should_receive(:resolved=).with( true)
    up2.should_receive(:resolved=).with( true)
    @page.stub!(:user_participations).and_return([up1, up2])
    @page.should_receive(:save)
    @page.should_receive(:resolved=)
    @page.resolve
  end

  it "should unresolve user participations when unresolving" do
    up1 = mock_model( UserParticipation, :resolved= => nil, :save => nil )
    up2 = mock_model( UserParticipation, :resolved= => nil, :save => nil )
    up1.should_receive(:resolved=).with(false)
    up2.should_receive(:resolved=).with(false)
    @page.stub!(:user_participations).and_return([up1, up2])
    @page.should_receive(:resolved=).with(false)
    @page.unresolve
  end

  describe "when saving tags" do
    it "accepts tag_with calls" do
      @page.should respond_to(:tag_with)
    end
    it "gives back the tags we give it" do
      @page.save
      @page.tag_with( "noodles soup")
      @page.tag_list.should include("noodles")
    end
    it "read tags with tag_list" do
      @page.save
      @page.tag_with "noodles soup"
      @page.tag_list.should include("soup")
    end
  end

  describe "when finding by path" do
    it "finds by tag" do
      p = Page.create :title => 'page1'
      p.tag_with 'tag1'
      pages = Page.find_by_path("/tag/tag1")
      pages.should include(p)
    end

    it "finds by multiple tags" do
      p = Page.create :title => 'page1'
      p.tag_with 'tag1 tag2'
      p2 = Page.create :title => 'page2'
      p2.tag_with 'tag2 tag3'
      p3 = Page.create :title => 'page3'
      p3.tag_with 'tag3 tag4'

      pages = Page.find_by_path("/tag/tag1/tag/tag2")
      pages.should include(p)
      pages.should_not include(p3)
      pages.each do |page|
        page.tag_list.should include('tag1')
        page.tag_list.should include('tag2')
        page.tag_list.should_not include('tag4')
      end
    end
  end
end
