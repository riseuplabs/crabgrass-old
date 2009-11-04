require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :pages, :users
  def setup
    @objs = Page.find(:all, :limit => 2)

    @obj1 = @objs[0]
    @obj1.tag_list = "pale"
    @obj1.save

    @obj2 = @objs[1]
    @obj2.tag_list = "pale, imperial"
    @obj2.save
  end

  def test_tag_list
    @obj2.tag_list = "hoppy, pilsner"
    assert_equal ["hoppy", "pilsner"], @obj2.tag_list
  end

  def test_find_tagged_with
    @obj1.tag_list = "seasonal, lager, ipa"
    @obj1.save
    @obj2.tag_list = "lager, stout, fruity, seasonal"
    @obj2.save

    result1 = [@obj1]
    assert_equal Page.find_tagged_with("ipa", :on => :tags), result1

    result2 = [@obj1.id, @obj2.id].sort
    assert_equal result2, Page.find_tagged_with("seasonal", :on => :tags).map(&:id).sort
    assert_equal result2, Page.find_tagged_with(["seasonal", "lager"], :on => :tags).map(&:id).sort
  end

  def test_users_tag_cache
    user = User.make :login => 'fishy', :password => 'xxxxxx', :password_confirmation => 'xxxxxx'
    page = Page.make :title => 'hi'
    page.tag_list = 'one, two'
    page.save!

    assert !page.users.include?(user)
    assert user.tags.empty?

    page.add(user)
    page.save!

    user.update_tag_cache  ## TODO: make this work without calling this manually.
    user.reload            ##

    assert user.tags.include?(page.tags.first), user.tags.inspect
  end

  def test_create_with_tags
    page = nil
    assert_nothing_raised do
      page = DiscussionPage.create! :title => 'tag me!', :tag_list => 'one,two,three'
    end
    assert page.tag_list.include?('one')
    page = Page.find(page.id)
    assert page.tag_list.include?('one')
  end

end
