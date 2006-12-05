require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase

  fixtures :pages, :users
  
  def setup
    @page = create_page :title => 'this is a very fine test page'
    @discussion = Discussion.create
    @page_tool_count = @page.tools.length
  end
 
  def test_tool_assignment
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
   
  def test_user_associations
    user = User.find 3
    @page.created_by = user
    @page.save
    assert_not_nil @page.created_by
    assert_nil @page.updated_by
    assert user.pages_created.first == @page
    
    @page.updated_by = user
    @page.save
    assert user.pages_updated.first == @page
    
    ## @page.users << user
    ## ^^^^^^^^^^^^^^^^^^^^ doesn't work until 1.2, instead we must:
    UserParticipation.create :user => user, :page => @page
    assert @page.users.include?(user)
    assert user.pages.include?(@page)
    @page.save
    @page.reload
    assert @page.users.include?(user)
    assert user.pages.include?(@page)
  end
  
  def test_page_links
    p1 = create_page :title => 'red fish'
    p2 = create_page :title => 'two fish'
    p3 = create_page :title => 'blue fish'
    
    p1.pages << p2              
    assert_equal p1.pages.length, 1
    assert_equal p2.pages.length, 1
    assert_equal p1.pages.first.title, p2.title
    assert_equal p2.pages.first.title, p1.title
    
    p1.pages << p3
    assert_equal p1.pages.length, 2
    assert_equal p3.pages.length, 1
    assert p1.pages.include?(p3)
    
    #p1.pages << p3
    #p1.pages << p3
    #p1.save
    #assert_equal 2, p1.pages.length, 'shouldnt be able to add same link twice'
    
  end

  def test_associations
    assert check_associations(Page)
  end
  
  protected
    def create_page(options = {})
      defaults = {:title => 'untitled page', :public => false}
      Page.create(defaults.merge(options))
    end
end
