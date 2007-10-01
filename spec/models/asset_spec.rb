require File.dirname(__FILE__) + '/../spec_helper'


describe Asset, "when updating" do
#  fixtures :assets
  before(:all) do
    @old_file_storage = Asset.file_storage
    @old_public_storage = Asset.public_storage
    Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
    Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"
  end
  after(:all) do
    Asset.file_storage = @old_file_storage
    Asset.public_storage = @old_public_storage
  end
  before do
    FileUtils.mkdir_p(Asset.file_storage)
    FileUtils.mkdir_p(Asset.public_storage)
    @asset = Asset.new :uploaded_data => ActionController::TestUploadedFile.new(asset_fixture_path('gears.jpg'), 'image/jpg')
  end
  after do
    FileUtils.rm_rf(Asset.file_storage)
    FileUtils.rm_rf(Asset.public_storage)
  end

  it "should remember the old filename" do
    @asset.save
    filename = @asset.filename
    @asset.uploaded_data = ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')
    File.basename(@asset.old_filename).should == filename
    File.basename(@asset.filename).should == 'gears2.jpg'
  end

  it "should remember old filename when it's time to copy asset" do
    @asset.save
    lambda {
    @asset.update_attribute(:uploaded_data, ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')) #uploaded_data= + save
    }.should_not raise_error
  end
end
