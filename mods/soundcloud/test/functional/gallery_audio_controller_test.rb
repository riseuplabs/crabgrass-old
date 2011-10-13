require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryAudioControllerTest < ActionController::TestCase


  def setup
    @user = User.make

    # let's make some gallery
    @gallery = Gallery.create! :title => 'gimme pictures', :user => @user
    @gallery.stubs(:save).returns(true)
    Page.expects(:find).with(@gallery.id.to_s).returns(@gallery)
  end

  def test_create
    showing = mock
    asset_data = stub
    track_stub = stub(:save => true)
    showing.expects(:create_track).with(:asset_data => asset_data).returns(track_stub)
    showing.expects(:save).returns(:true)
    showings = mock
    showings.expects(:find).with(1).returns(showing)
    @gallery.stubs(:showings).returns(showings)

    login_as @user
    post :create, :page_id => @gallery.id,
      :assets => [asset_data],
      :track => { :showing_id => 1 }
    assert_response :redirect
  end

  def test_update
    login_as @user
    track = mock @showing.create_track :asset_data => upload_data('image.png')
    post :update, :page_id => @gallery.id,
      :id => track.id,
      :track => { :permalink_url => 'changed',
        :assets => [upload_data('photo.jpg')] }
    assert_response :success
    assert_equal 'changed', track.reload.permalink_url
    assert_equal 'photo.jpg', track.reload.title
  end

  def test_destroy
    track = @showing.create_track :asset_data => upload_data('image.png')
    login_as @user
    delete :destroy, :page_id => @gallery.id,
      :id => track.id
    assert_response :redirect
    assert_redirect_to page_url(@gallery, :action => :edit)
    assert_nil @showing.track
  end

end
