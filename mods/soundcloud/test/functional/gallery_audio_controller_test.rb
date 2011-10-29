require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryAudioControllerTest < ActionController::TestCase


  def setup
    @user = User.make
    @gallery = stub :new_record? => false,
      :has_access? => true,
      :owner_name => 'page_owner',
      :name_url => 'page-title'
    Page.expects(:find).with('9').returns(@gallery)
  end

  def test_create
    asset_data = stub
    track_stub = stub(:new_record? => false)
    params = { :asset_data => asset_data,
      :showing_id => 5 }
    Track.expects(:create_for_page).with(@gallery, params).returns(track_stub)

    login_as @user
    post :create, :page_id => 9,
      :assets => [asset_data],
      :track => { :showing_id => 5 }
    assert_response :redirect
    assert_equal track_stub, assigns['track']
  end

  def test_update
    asset_data = stub
    track = mock
    track.expects(:update_attributes, {:asset_data => asset_data}).returns(track)
    mock_tracks(@gallery, track)

    login_as @user
    post :update, :page_id => 9,
      :id => 7,
      :assets => [asset_data]
    assert_response :redirect
    assert_equal track, assigns['track']
  end

  def test_destroy
    track = mock
    track.expects(:destroy)
    mock_tracks(@gallery, track)

    login_as @user
    delete :destroy, :page_id => 9,
      :id => 7
    assert_response :redirect
  end

  private

  def mock_tracks(gallery, track)
    tracks = mock
    tracks.expects(:find).with('7').returns(track)
    gallery.stubs(:tracks).returns(tracks)
  end

end
