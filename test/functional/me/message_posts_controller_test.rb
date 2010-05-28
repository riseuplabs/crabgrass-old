require File.dirname(__FILE__) + '/../../test_helper'

class Me::MessagePostsControllerTest < ActionController::TestCase
  fixtures :users, :relationships, :discussions


  def test_create_message_post
    login_as :blue

    assert_difference 'Post.count' do
      post :create, :message_id => users(:orange).to_param, :post => {:body => "blue: hi orange"}
    end

    assert_equal "blue: hi orange", users(:blue).relationships.with(users(:orange)).discussion.posts.last.body
    assert_redirected_to message_path('orange')
  end


  def test_cant_create_without_login
    assert_no_difference 'Post.count' do
      post :create, :message_id => users(:orange).to_param, :post => {:body => "blue: hi orange"}
    end
    assert_login_required
  end

  def test_cant_pester
    # login as gerrard and message orange
    # these should never be friends, because friends can always pester each other
    login_as :gerrard

    users(:orange).profiles.public.update_attribute(:may_pester, false)

    assert_no_difference 'Post.count' do
      post :create, :message_id => users(:orange).to_param, :post => {:body => "gerrard: hi orange"}
    end

    assert_redirected_to messages_path
  end

  def test_recipient_cant_be_self
    login_as :blue

    assert_no_difference 'Post.count' do
      post :create, :message_id => users(:blue).to_param, :post => {:body => "blue: hi blue, you're my favorite color!"}
    end

    assert_redirected_to messages_path
  end
end
