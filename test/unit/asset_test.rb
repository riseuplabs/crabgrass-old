require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < Test::Unit::TestCase
#  fixtures :groups

  Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
  Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"

  def setup
    FileUtils.mkdir_p(Asset.file_storage)
    FileUtils.mkdir_p(Asset.public_storage)
  end

  def teardown
    FileUtils.rm_rf(Asset.file_storage)
    FileUtils.rm_rf(File.dirname(Asset.public_storage))
  end

  #XXX:warning, extremely brittle test
  def test_file_storage
    @asset = Asset.new :filename => 'image.jpg'
    assert_match /#{Asset.file_storage}\/\d{4}\/\d{4}\/#{@asset.filename}/, @asset.full_filename
  end
  
  def test_access
    @asset = Asset.create :uploaded_data => fixture_file_upload(File.join('files','gears.jpg'), 'image/jpg')
    assert File.exists?(@asset.full_filename)
    assert @asset.is_public?
    @asset.update_access
    assert File.exists?(@asset.public_dirpath)
#    assert File.stat(@asset.public_dirpath).symlink?
    @asset.instance_eval do
      def is_public?
        false
      end
    end
    @asset.update_access
    assert !File.exists?(@asset.public_dirpath)
  end

  def test_asset_links_should_be_removed_when_asset_is_destroyed
    @asset = Asset.create :uploaded_data => fixture_file_upload(File.join('files','gears.jpg'), 'image/jpg')
    assert File.exists?(@asset.full_filename)
    @asset.update_access
    assert File.exists?(@asset.public_dirpath)
    @asset.destroy
    assert !File.exists?(@asset.full_filename)
    assert !File.exists?(@asset.public_dirpath)
  end
end
