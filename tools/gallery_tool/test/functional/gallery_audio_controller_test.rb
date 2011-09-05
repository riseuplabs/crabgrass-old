require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryAudioControllerTest < ActionController::TestCase


  def setup
    # let's make some gallery
    # there are no galleries in fixtures yet.
    #
    @user = User.make
    @gallery = Gallery.create! :title => 'gimme pictures', :user => @user
    @asset = Asset.create_from_params({
      :uploaded_data => upload_data('photo.jpg')}) do |asset|
        asset.parent_page = @gallery
      end
    @gallery.add_image!(@asset, @user)
    @showing = @gallery.showings.last
    @gallery.save!
    @asset.save!
  end

  def test_create
    login_as @user
    post :create, :page_id => @gallery.id,
      :showing_id => @showing.id,
      :track => {:permalink_url => 'my permalink'}
    assert_response :success
  end


end
