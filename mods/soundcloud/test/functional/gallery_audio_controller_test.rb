require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryAudioControllerTest < ActionController::TestCase


  def setup
    @user = User.make
    @gallery = stub :participation_for_user => stub,
      :new_record? => false,
      :has_access! => true,
      :discussion => stub
    Page.stubs(:find).returns(@gallery)
  end

  def test_create
    asset_data = stub
    track_stub = stub(:new_record? => false)
    params = { :asset_data => asset_data,
      :showing_id => '1' }
    Track.expects(:create_for_page).with(@gallery, params).returns(track_stub)

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
