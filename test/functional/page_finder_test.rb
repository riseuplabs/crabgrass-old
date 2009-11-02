=begin

A test for the Page.find_by_path ability (the code for this is in lib/path_finder)

The general strategy here is to get a set of page ids using a brute force method
(such as loading all the pages and rejecting or accepting them using ruby code
instead of mysql conditions), and then we compare this set of 'reference' page ids
to the set of page ids return by the find_by_path method.

If the sets differ, then the find_by_path method fucked up and it is back to the
drawing board.

=end

require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'
require 'set'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class PageFinderTest < Test::Unit::TestCase
  fixtures :groups, :users, :memberships, :pages, :sites,
   :user_participations, :group_participations, :taggings, :tags

  def setup
    @controller = AccountController.new # it doesn't matter which controller, really.
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    disable_site_testing
  end

  def test_group_pages_not_authed
    dont_login
    group = groups(:rainbow)

    gparts = GroupParticipation.find( :all, :conditions => ['group_id = ?', group.id])
    reference_ids = page_ids(gparts) do |page|
      true if page.public? and page.flow == nil
    end
    path_ids = page_ids(Page.find_by_path('/', @controller.options_for_group(group)))

    assert_equal reference_ids, path_ids, 'page ids sets must be equal'
  end

  def test_group_pages_authed
    login(:blue)
    user = users(:blue)
    group = groups(:rainbow)

    gparts = GroupParticipation.find( :all, :conditions => ['group_id = ?', group.id])
    reference_ids = page_ids(gparts) do |page|
      true if (page.public? or user.may?(:view,page)) and page.flow == nil
    end
    path_ids = page_ids(Page.find_by_path('/', @controller.options_for_group(group)))

    assert_equal reference_ids, path_ids, 'page ids sets must be equal (difference = %s)' % (reference_ids - path_ids)
  end

  def test_dashboard
    login(:red)
    user = users(:red)

    pages = Page.find( :all, :conditions => ['flow IS NULL'] )
    pages = sort_descending(pages, 'updated_at')
    pages = pages.select do |page|
      user.may?(:view,page)
    end
    pages = limit(pages,20)
    reference_ids = page_ids(pages)

    path_ids = page_ids(
      Page.find_by_path('/descending/updated_at/limit/20', @controller.options_for_me() )
    )

    (reference_ids - path_ids).each do |pid|
      puts 'in reference but not in path'
      debug(Page.find(pid),user)
    end
    (path_ids - reference_ids).each do |pid|
      puts 'in path but not in reference'
      debug(Page.find(pid),user)
    end
    assert_equal reference_ids, path_ids, 'page ids sets must be equal'
  end

  def test_user_pages_authed
    login(:blue)
    current_user = users(:blue)
    user = users(:red)

    uparts = UserParticipation.find :all, :conditions => ['user_id = ?', user.id]
    reference_ids = page_ids(uparts) do |page|
      true if current_user.may?(:view,page) or page.public?
    end

    pages = Page.find_by_path('/',@controller.options_for_user(user))
    path_ids = page_ids(pages)

    assert_equal reference_ids, path_ids, 'page ids sets must be equal'
  end

  def test_unread_inbox_count
    login(:blue)
    user = users(:blue)

    uparts = UserParticipation.find :all, :conditions => ['user_id = ? AND inbox = ? AND viewed = ?', user.id, true, false]
    unread_count = Page.count_by_path('unread', @controller.options_for_inbox)

    assert_equal uparts.size, unread_count, 'unread inbox counts should match'
  end

  def test_inbox_pending
    login(:blue)
    user = users(:blue)

    uparts = UserParticipation.find :all, :conditions => ['user_id = ? AND inbox = ? AND resolved = ?', user.id, true, false]
    reference_ids = page_ids(uparts)
    pages = Page.find_by_path('pending', @controller.options_for_inbox)
    path_ids = page_ids(pages)

    assert_equal reference_ids, path_ids, 'pending inbox pages should match'
  end

  def test_pagination
    login(:blue)
    user = users(:blue)

    pages = Page.find( :all, :conditions => ['flow IS NULL'] )
    pages = sort_descending(pages, 'updated_at')
    pages = pages.select do |page|
      user.may?(:view,page)
    end
    pages = limit(pages,10)
    reference_ids = page_ids(pages)

    options = @controller.options_for_me(:page => 1, :per_page => 10)
    pages = Page.paginate_by_path('/descending/updated_at/', options)
    path_ids = page_ids(pages)

    assert_equal reference_ids, path_ids, 'pagination pages should match'
  end

  def test_flow
    dont_login

    flow_page = pages(:delete_test)
    pages = Page.find_by_path('/',:flow => :deleted)
    assert_not_nil pages, 'find with flow condition should return one page'
    assert_equal flow_page.id, pages.first.id, 'find with flow condition should return :flow_test'
  end

  def test_tagging
    user = User.make
    login(user)

    name = 'test page'
    page = WikiPage.make_unsaved :title => name.titleize, :name => name.nameize, :created_by => user
    page.save
    page.add(user)
    rainbow_group = Group.make
    page.add(rainbow_group)
    page.tag_list = "pig, fish, elephant"
    page.save!

    pages = Page.find_by_path('/tag/fish/', @controller.options_for_group(rainbow_group))
    assert_equal page.id, pages.first.id, 'find by tag should return correct page'

    pages = Page.find_by_path('/tag/fish/', @controller.options_for_me)
    assert_equal page.id, pages.first.id, 'find by tag should return correct page, for me'
  end

  def test_group_tasks
    login(:blue)
    group = groups(:rainbow)

    gparts = GroupParticipation.find :all, :conditions => ['group_id = ?', group.id]
    reference_ids = page_ids(gparts) do |page|
      true if page.instance_of? TaskListPage and !page.resolved?
    end

    pages = Page.find_by_path('type/task/pending', @controller.options_for_group( groups(:rainbow) ))
    path_ids = page_ids(pages)

    assert_equal reference_ids, path_ids, "find_by_path should return all of a group's task lists"
  end

  def test_options_for_me

    login(:blue)
    user = users(:blue)
    group = groups(:rainbow)

    pages = Page.find( :all, :conditions => ['flow IS NULL'] )
    pages = pages.select do |page|
      group.may?(:view,page) and user.may?(:view,page)
    end
    reference_ids = page_ids(pages)

    path_ids = page_ids(
      Page.find_by_path('/group/%s'%group.id, @controller.options_for_me() )
    )

    (reference_ids - path_ids).each do |pid|
      puts 'in reference but not in path: id=%s'%pid
      debug(Page.find(pid),user)
    end
    (path_ids - reference_ids).each do |pid|
      puts 'in path but not in reference: id=%s'%pid
      debug(Page.find(pid),user)
    end
    assert_equal reference_ids, path_ids, 'page ids sets must be equal'
  end


  def test_stress
    # normally, we don't run this test because it takes too long.
    # run like so: ruby page_finder_test -n test_stress
    # and comment out this next line:
    return true
    pages = []
    groups = []
    login(:blue)
    user = users(:blue)

    puts 'creating and joining groups: '
    1000.times do |i|
      group = Group.create(:name => "group#{i}")
      group.add_user!(user)
      groups << group
      page = Page.create(:title => "page#{i}")
      page.add(group)
      page.page_terms.update_attribute(:access_ids, page.access_ids)
      print group.id
      print " "
      STDOUT.flush
    end

    puts 'finding pages: '
    groups.each do |group|
      benchmark{ pages = Page.find_by_path('', @controller.options_for_group(group) ) }
      assert_equal 1, pages.size, "group id = %s" % group.id
    end
  end

  protected

  def login(user = :blue)
    # starts a session and logs in as user 'blue'
    # 'login_as' must come before 'get', otherwise
    # session[:user] is set to false.
    # 'get' must happen, otherwise current_user blows up
    # in a way that I don't understand
    login_as user
    get :index
  end

  def dont_login
    get :index
  end

  # takes an array of Pages, UserParticipations, or GroupParticipations
  # and returns a Set of page ids. If a block is given, then the page
  # is passed to the block and if the block evaluates to false then
  # the page is not added to the set.
  def page_ids(array)
    return Set.new() unless array.any?
    if array.first.instance_of?(UserParticipation) or array.first.instance_of?(GroupParticipation)
      Set.new(
        array.collect{|part|
          if block_given?
            part.page_id if yield(part.page)
          else
            part.page_id
          end
        }.compact
      )
    elsif array.first.is_a?(Page)
      Set.new(
        array.collect{|page|
          if block_given?
            page.id if yield(page)
          else
            page.id
          end
        }.compact
      )
    else
      puts 'error in page_ids(%s)' % array.class
      puts array.first.class.to_s
      puts caller().inspect
      exit
    end
  end

  def sort_descending(pages,field)
    pages.compact.sort{|a,b| (b.send(field)||0).to_i <=> (a.send(field)||0).to_i }
  end

  def sort_ascending(pages,field)
    pages.compact.sort{|a,b| (a.send(field)||0).to_i <=> (b.send(field)||0).to_i }
  end

  def limit(pages,limit)
    pages[0..(limit-1)]
  end

  def benchmark
    cur = Time.now
    result = yield
    print "#{cur = Time.now - cur} seconds"
    puts " (#{(cur / $last_benchmark * 100).to_i - 100}% change)" rescue puts ""
    $last_benchmark = cur
    result
  end


  def debug(page, user)
   puts '------ page ------'
   puts '         id: %s' % page.id
   puts ' updated_at: %s' % page.updated_at
   puts '  may? view: %s' % user.may?(:view,page)
   puts 'group parts:'
   page.group_participations.each do |gpart|
     puts '        id: %s'%gpart.id
     puts '  group_id: %s'%gpart.group_id
     puts '     group: %s'%gpart.group.name
     puts '     -----'
   end
   puts 'user parts:'
   page.user_participations.each do |upart|
     puts '        id: %s'%upart.id
     puts '   user_id: %s'%upart.user_id
     puts '      user: %s'%upart.user.name
     puts '     -----'
   end
  end

end
