require File.dirname(__FILE__) + '/../../test_helper'

class Me::MessagesControllerTest < ActionController::TestCase
  fixtures :users, :relationships, :discussions

  def test_should_get_index
    get :index
    assert_login_required

    login_as :blue
    get :index
    assert_response :success
  end

  # testing for #1931
  def test_banner_image_should_link_to_profile
    login_as :blue
    get :index
    assert_select 'div.banner' do
      assert_select "a[href='/blue']" do
        assert_select 'img.left'
      end
    end
  end

  def test_should_not_show_nonexisting_conversation
    login_as :yellow
    get :show, :id => users(:orange).to_param

    assert_redirected_to :action => :index
  end

  def test_should_show_conversation
    blue = users(:blue)
    orange = users(:orange)

    relationship = orange.relationships.with(blue)

    get :show, :id => users(:orange).to_param
    assert_login_required

    # should assign discussion
    login_as :blue
    get :show, :id => users(:orange).to_param
    assert_response :success
    assert_equal relationship.discussion, assigns(:discussion)
    # test for #1919
    assert_equal users(:blue), assigns(:user)
    assert_equal users(:orange), assigns(:recipient)
    # test for #1918
    assert_select "a[href=#{messages_path}]", 'Back to Messages'

    # same discussion, from a different perspective
    login_as :orange
    get :show, :id => users(:blue).to_param
    assert_response :success
    assert_equal relationship.discussion, assigns(:discussion)
  end


  def test_mark_conversations
    make_messages_for_blue

    # blue should have 3 unread messages
    assert @blue_orange_discussion.unread_by?(@blue)
    assert @blue_red_discussion.unread_by?(@blue)
    assert @blue_green_discussion.unread_by?(@blue)

    login_as :blue
    xhr :put, :mark, :as => :read, :messages => [@blue_orange_discussion.id, @blue_green_discussion.id]

    assert_response :success

    # blue should have 1 unread message
    assert !@blue_orange_discussion.reload.unread_by?(@blue)
    assert @blue_red_discussion.reload.unread_by?(@blue)
    assert !@blue_green_discussion.reload.unread_by?(@blue)
  end

  def test_view_filter
    make_messages_for_blue
    @blue_orange_discussion.mark!(:read, @blue)

    login_as :blue

    get :index, :view => :unread
    assert_same_elements [@blue_red_discussion, @blue_green_discussion], assigns(:discussions)

    get :index, :view => :all
    assert_same_elements [@blue_orange_discussion.reload, @blue_red_discussion.reload, @blue_green_discussion.reload],
                  assigns(:discussions)
  end



  def test_next_and_previous
    make_messages_for_blue

    login_as :blue

    all_discussions = @blue.discussions.with_some_posts
    first, middle, last = *all_discussions

    # get username that identifies this discussion for blue
    first_id = first.user_talking_to(@blue).to_param
    middle_id = middle.user_talking_to(@blue).to_param
    last_id = last.user_talking_to(@blue).to_param


    get :show, :id => middle_id
    # test for #1920
    assert_select 'a.left', '« Previous'
    assert_select 'a.right', 'Next »'
    # asking for next while on last item
    # or for previous while on first item
    # should return you to index
    get :previous, :id => first_id
    assert_redirected_to :action => :index

    get :next, :id => first_id
    assert_redirected_to :action => :show, :id => middle_id

    get :previous, :id => last_id
    assert_redirected_to :action => :show, :id => middle_id

    get :next, :id => last_id
    assert_redirected_to :action => :index
  end


  protected

  def make_messages_for_blue
    @blue = users(:blue)
    @orange = users(:orange)
    @red = users(:red)
    @green = users(:green)

    @blue_orange_discussion = @blue.relationships.with(@orange).discussion
    @blue_red_discussion = @blue.relationships.with(@red).discussion
    @blue_green_discussion = @blue.relationships.with(@green).discussion

    # 3 users send messages to blue
    @orange.send_message_to!(@blue, "orange: hi blue")
    @red.send_message_to!(@blue, "red: hi blue")
    @green.send_message_to!(@blue, "green: hi blue")

    # fix timestamps for deterministic sorting
    all_discussions = @blue.discussions.with_some_posts
    time = Time.now
    all_discussions.reverse.each_with_index do |discussion, index|
      discussion.update_attribute(:replied_at, time - index)
    end
  end

end
