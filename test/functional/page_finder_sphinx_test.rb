=begin

  a sphinx specific test.

=end

require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'
require 'set'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class PageFinderSphinxTest < Test::Unit::TestCase
  fixtures :groups, :users, :memberships, :pages, :page_terms,
   :user_participations, :group_participations, :taggings, :tags
  
  def setup
    @controller = AccountController.new # it doesn't matter which controller, really.
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  ##############################################
  ### Tests for various search parameters

  def try_many_sphinx_searches(user)
    searches = [ 
      ['/pending', Proc.new {|p| p.resolved == false}  ],

      ['/type/discussion', Proc.new {|p| p.type == "DiscussionPage"} ],
      ['/type/event',      Proc.new {|p| p.type == "EventPage"} ],
      ['/type/message',    Proc.new {|p| p.type == "MessagePage"} ],
      ['/type/poll',       Proc.new {|p| p.type == "RateManyPage"} ],
      ['/type/task',       Proc.new {|p| p.type == "TaskListPage"} ],
      ['/type/vote',       Proc.new {|p| p.type == "RankedVotePage"} ],
      ['/type/wiki',       Proc.new {|p| p.type == "WikiPage"} ],

      ['/person/1', Proc.new {|p| User.find(1).may?(:view,p)} ],

      ['/group/1', Proc.new {|p| Group.find(1).may?(:view,p)} ],

      ['/created_by/4',     Proc.new {|p| p.created_by_id == 4} ],
      ['/created_by/1',     Proc.new {|p| p.created_by_id == 1} ],

      ['/not_created_by/1', Proc.new {|p| p.created_by_id != 1} ],

      ['/tag/pale', Proc.new {|p| p.tag_list.include? "pale"} ],
      ['/tag/pale/tag/imperial', Proc.new {|p| p.tag_list.include? "pale" and p.tag_list.include? "imperial"} ],
      ['/name/task', Proc.new {|p| p.name and p.name.include? "task"} ],
      ['/not_created_by/1', Proc.new {|p| p.created_by_id != 1} ]
    ]

    searches.each do |search_str, search_code|
      #puts 'trying... %s' % search_str
      sphinx_pages = Page.find_by_path(
        search_str, @controller.options_for_me(:method => :sphinx, :per_page => 1000)
      )
      raw_pages = Page.all(:order => "updated_at DESC").select{|p|
        search_code.call(p) and user.may?(:view, p)
      }
      assert_equal page_ids(raw_pages), page_ids(sphinx_pages), "#{search_str} should match results for user"
    end

    searches.each do |search_str, search_code|
      #puts 'trying... %s' % search_str
      sphinx_pages = Page.find_by_path(
        search_str, @controller.options_for_group(groups(:rainbow), :method => :sphinx, :per_page => 1000)
      )
      raw_pages = Page.find(:all).select{|p|
        search_code.call(p) and groups(:rainbow).may?(:view, p) and user.may?(:view, p)
      }
      assert_equal page_ids(raw_pages), page_ids(sphinx_pages), "#{search_str} should match results for group"
    end
  end  

  def test_sphinx_searches
    return unless sphinx_working?(:test_sphinx_searches)
    
    login(:blue)
    user = users(:blue)
    
    try_many_sphinx_searches user

=begin
    # the following test is not yet working
    ThinkingSphinx.deltas_enabled = true # will this make delta index active?
    # add some pages, and make sure that they appear in the sphinx search results
    (1..10).each do |i|
      p = Page.create :title => "new pending page #{i}"
      p.add user
      p.unresolve
      p.save
    end

    try_many_sphinx_searches user
=end

  end  

  def test_sphinx_search_text_doc
    return unless sphinx_working?(:test_sphinx_search_text_doc)
    
    # TODO: write this test
  end
  
  def test_sphinx_with_pagination
    return unless sphinx_working?(:test_sphinx_with_pagination)

    login(:blue)
    user = users(:blue)
    
    searches = [ 
      ['/descending/updated_at/limit/10', Proc.new {
        Page.find(:all, :order => "updated_at DESC").select{|p| user.may?(:view, p)}[0,10]
      }],
      ['/ascending/updated_at/limit/13', Proc.new {
        Page.find(:all, :order => "updated_at ASC").select{|p| user.may?(:view, p)}[0,13]
      }],
      ['/descending/created_at/limit/5', Proc.new {
        Page.find(:all, :order => "created_at DESC").select{|p| user.may?(:view, p)}[0,5]
      }],
      ['/ascending/created_at/limit/15', Proc.new {
        Page.find(:all, :order => "created_at ASC").select{|p| user.may?(:view, p)}[0,15]
      }],
   ]

    options = { :user_ids => [users(:blue).id], :group_ids => users(:blue).all_group_ids, :controller => @controller, :method => :sphinx }

    searches.each do |search_str, search_code|
      pages = Page.find_by_path(search_str, options)
      # require 'ruby_debug'; debugger
      assert_equal page_ids(search_code.call), page_ids(pages), "#{search_str} should match results for user when paginated"
    end
  end

  private

  def login(user = :blue)
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
    end
  end
end
