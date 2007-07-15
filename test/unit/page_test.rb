require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase

  fixtures :pages, :users, :groups

  def setup
    @page = create_page :title => 'this is a very fine test page'
    # @page_tool_count = @page.tools.length
  end

  # this is a test if we are using has_many_polymorphic
  # currently, we are using a single belongs_to that is polymorphic
  # for the relationship from page -> tool. 
  def disabled_test_multi_tool
    assert @page.tools.blank?
    assert @page.tools.push(@discussion)
    assert @page.tools.push(Discussion.create)
    assert_equal @page_tool_count += 2, @page.tools.length
    assert @page.tools.first.id == @discussion.id
    assert_equal 2, @page.discussions.length
    assert_equal 1, @discussion.pages.length
    assert @discussion.pages.first.title == @page.title, 'page title must match'
    assert @discussion.page.title == @page.title    
  end
  
  def test_tool
    assert poll = Poll::Poll.create
    assert poll.valid?, poll.errors.full_messages
    #poll.pages << @page
    @page.data = poll
    @page.save
    #poll.save
    #poll.reload
    assert_equal poll.pages.first, @page
    assert_equal @page.data, poll
  end

  def test_discussion
    assert discussion = Discussion.create
    assert discussion.valid?, discussion.errors.full_messages
    #discussion.pages << @page
    @page.discussion = discussion
    @page.save
    #discussion.save
    #discussion.reload
    assert_equal discussion.page, @page
    assert_equal @page.discussion, discussion
  end


  def test_user_associations
    user = User.find 3
    @page.created_by = user
    @page.save
    assert_not_nil @page.created_by
    assert_nil @page.updated_by
    #assert user.pages_created.first == @page
    
    @page.updated_by = user
    @page.save
    #assert user.pages_updated.first == @page
    
  end

  def test_participations
    user = User.find 3
	group = Group.find 3
    
    # page = build_page :title => 'zebra'
    #        ^^^^^ this doesn't work
    # assertions only work if the page is saved first.
    
    page = create_page :title => 'zebra'
        
	page.add(user, :star => true)
	page.add(group)
    
    assert page.users.include?(user), 'page must have an association with user'
    assert page.user_participations.find_by_user_id(user.id).star == true, 'user association attributes must be set'    
    assert page.groups.include?(group), 'page must have an association with group'
    assert user.pages.include?(page), 'user must have an association with page'
    assert group.pages.include?(page), 'group must have an association with page'
    
    page.save
    page.reload
    assert page.users.include?(user), 'page must have an association with user'
    assert page.user_participations.find_by_user_id(user.id).star == true, 'user association attributes must be set'
    assert page.groups.include?(group), 'page must have an association with group'
    assert user.pages.include?(page), 'user must have an association with page'
    assert group.pages.include?(page), 'group must have an association with page'
	
	page.remove(user)
	page.remove(group)
    assert !page.users.include?(user), 'page must NOT have an association with user'
    assert !page.groups.include?(group), 'page must NOT have an association with group'
	
  end
  
  def test_denormalized
    user = User.find 3
	group = Group.find 3
    p = create_page :title => 'oak tree'
    p.add(group)
    p.save
    assert_equal group.name, p.group_name, 'page should have a denormalized copy of the group name'
  end
  
  def test_page_links
    p1 = create_page :title => 'red fish'
    p2 = create_page :title => 'two fish'
    p3 = create_page :title => 'blue fish'
    
    p1.add_link p2              
    assert_equal p1.links.length, 1
    assert_equal p2.links.length, 1
    assert_equal p1.links.first.title, p2.title
    assert_equal p2.links.first.title, p1.title
   
    p1.add_link p3
    assert_equal p1.links.length, 2
    assert_equal p3.links.length, 1
    assert p1.links.include?(p3)
    
    p1.add_link p3
    p1.add_link p3
    p1.save
    assert_equal 2, p1.links.length, 'shouldnt be able to add same link twice'
    
    p2.destroy
    assert_equal 1, p1.links.length, 'after destroy, links should be removed'
  end

  def test_associations
    assert check_associations(Page)
  end
  
  protected
  
  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    Page.create(defaults.merge(options))
  end
  
  def build_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    Page.new(defaults.merge(options))
  end
end
