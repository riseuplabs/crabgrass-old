module AssetTestHelper
  include ActionController::TestProcess # fixture_file_upload
  ##
  ## ASSET HELPERS
  ##

  def upload_data(file)
    type = 'image/png' if file =~ /\.png$/
    type = 'image/jpeg' if file =~ /\.jpg$/
    type = 'application/msword' if file =~ /\.doc$/
    type = 'application/octet-stream' if file =~ /\.bin$/
    type = 'application/zip' if file =~ /\.zip$/
    fixture_file_upload('files/'+file, type)
  end

  def upload_avatar(file)
    MockFile.new(RAILS_ROOT + '/test/fixtures/files/' + file)
  end

  def read_file(file)
    File.read( RAILS_ROOT + '/test/fixtures/files/' + file )
  end
end
