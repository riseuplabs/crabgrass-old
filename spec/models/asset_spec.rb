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

  it "should update attachment filename when saving a new version" do
    @asset.save
    @asset.uploaded_data = ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')
    @asset.save
    File.basename(@asset.filename).should == 'gears2.jpg'
    File.basename(@asset.versions.first.filename).should == 'gears.jpg'
  end

  it "should copy attachment data when saving a new version" do
    @asset.save
    @asset.uploaded_data = ActionController::TestUploadedFile.new(asset_fixture_path('image.png'), 'image/png')
    @asset.save
    File.read(@asset.full_filename).should == File.read(asset_fixture_path('image.png'))
    File.read(@asset.versions.first.full_filename).should == File.read(asset_fixture_path('gears.jpg'))
    File.read(@asset.full_filename).should_not == File.read(@asset.versions.first.full_filename)
  end

  it "should remember old filename when it's time to copy asset" do
    @asset.save
    lambda {
    @asset.update_attribute(:uploaded_data, ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')) #uploaded_data= + save
    }.should_not raise_error
  end
end
