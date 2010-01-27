require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  fixtures :users, :relationships, :discussions

  def test_should_get_index
    get :index
    assert_login_required

    login_as :blue
    get :index
    assert_response :success
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
    assert_equal [@blue_red_discussion, @blue_green_discussion], assigns(:discussions)

    get :index, :view => :all
    assert_equal [@blue_orange_discussion.reload, @blue_red_discussion.reload, @blue_green_discussion.reload],
                  assigns(:discussions)
  end




  def test_next_and_previous
    make_messages_for_blue

    login_as :blue

    ### for user 'orange' (first in the list)
    # getting previous on earliest message goes to index
    get :previous, :id => users(:orange).to_param
    assert_redirected_to :action => :index

    get :next, :id => users(:orange).to_param
    assert_redirected_to :action => :show, :id => 'red'

    ### for user 'green' (last in the list)
    get :previous, :id => users(:green).to_param
    assert_redirected_to :action => :show, :id => 'red'

    # getting next on last item should redirect to index
    get :next, :id => users(:green).to_param
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
  end

end
