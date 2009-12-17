require File.dirname(__FILE__) + '/../../test_helper'

class Admin::DiscussionPostsControllerTest < ActionController::TestCase
  fixtures :pages, :user_participations, :group_participations, :discussions

  def setup
    setup_site_with_moderation
    @flagger = User.make
  end

  def test_yucky_shows_up
    with_site "moderation" do
      login_as @mod
      assert_none_in_view 'new'
      new_post = Post.make
      make_yucky(new_post)
      assert_in_view 'new', [new_post]
    end
  end

  # TODO: CRUD is currently broken.
  # post :update, :id => new_post.id,
  #  :post => {:deleted => :true},
  #  :view => :deleted
  # instead we do
  def test_deleted_shows_up
    with_site "moderation" do
      login_as @mod
      new_post = Post.make
      make_yucky(new_post)
      post :trash, :id => new_post.id,
        :view => :deleted
      assert_response :redirect
      assert_redirected_to :action => :index, :view => 'deleted'
      assert_in_view 'deleted', [new_post]
      assert_none_in_view 'new'
    end
  end

  def assert_in_view(view, objects)
    get :index, :view => view
    assert_response :success
    assert_equal objects.map(&:id), assigns(:flagged).map(&:id)
    assert_equal objects.map(&:type), assigns(:flagged).map(&:type)
  end

  def assert_none_in_view(view)
    get :index, :view => view
    assert_response :success
    assert_equal [], assigns(:flagged)
  end

  def make_yucky(comment, reason = 'language')
    ModeratedFlag.create(:flagged => comment, :reason_flagged => reason)
  end
end
