require File.dirname(__FILE__) + '/../spec_helper'

describe Asset, "when updating" do
#  fixtures :assets

  before do
    @asset = Asset.create :uploaded_data => ActionController::TestUploadedFile.new(asset_fixture_path('gears.jpg'), 'image/jpg')
  end

  it "should remember the old filename" do
    filename = @asset.filename
    @asset.uploaded_data = ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')
    File.basename(@asset.instance_variable_get(:@old_filename)).should == filename
  end

=begin
  it "should receive a call to the filename setter" do
    @asset.expects(:filename=).once
    @asset.uploaded_data = ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')
    @asset.save
  end
=end

  it "should save the new file with the name of the asset page" do
    full_filename = @asset.full_filename
    @asset.uploaded_data = ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')
    @asset.save
    @asset.full_filename.should == full_filename
  end

#  it "should create a version folder if one doesn't exist"

  it "should put the old file in the versions folder" do
    @asset.uploaded_data = ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')
    File.exists?(File.join(@asset.full_dirpath, 'versions')).should be_true
  end

end
