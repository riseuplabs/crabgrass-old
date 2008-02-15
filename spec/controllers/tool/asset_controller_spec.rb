require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::AssetController do
  it "should keep the page title as the filename for new versions" do
    @asset = Asset.new :filename => 'pagetitle.gif'
    @page = stub_everything
    @page.stub!(:data).and_return(@asset)
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:fetch_page_data).and_return(true)
    controller.instance_variable_set(:@page, @page)
    @page.stub!(:title).and_return('pagetitle')
    @asset.filename = 'pagetitle.gif'
    post 'update', {:asset => ActionController::TestUploadedFile.new(asset_fixture_path('gears.jpg'), 'image/jpg')}
    response.should be_redirect
    @asset.filename.should == 'pagetitle.jpg'
  end
end

