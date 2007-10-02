require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::AssetController do
  before do
    @asset = Asset.new
    @page = stub_everything(:data => @asset)
    Page.stubs(:find).returns(@page)
  end

  it "should keep the page title as the filename for new versions" do
    controller.stubs(:login_required).returns(true)
    controller.stubs(:fetch_page_data).returns(true)
    controller.instance_variable_set(:@page, @page)
    @page.stubs(:title).returns('pagetitle')
    @asset.filename = 'pagetitle.gif'
    post 'update', {:asset => ActionController::TestUploadedFile.new(asset_fixture_path('gears.jpg'), 'image/jpg')}
    response.should be_redirect
    @asset.filename.should == 'pagetitle.jpg'
  end
end

