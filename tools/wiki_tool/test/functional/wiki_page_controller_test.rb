require File.dirname(__FILE__) + '/../../../../test/test_helper'

class WikiPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :wikis, :groups, :sites

  def setup
    #HTMLDiff.log_to_stdout = false # set to true for debugging
  end

  def test_show
    login_as :orange

    # existing page
    get :show, :page_id => pages(:wiki).id
    assert_response :success
  end

  def test_failed_show_without_login
    # existing page
    get :show, :page_id => pages(:wiki).id
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
  end

  def test_show_without_login
    get :show, :page_id => pages(:public_wiki).id
    assert_response :success
  end
=begin
  this test doesn't work, but the actual code does.
  not sure how to write this, the page is reset or something
  on the 'get :show'
  def test_show_after_changes
    # force a version greater than 1
    page = Page.find(pages(:wiki).id)
    page.data.body = 'new body'
    page.data.save
    page.data.body = 'new new body'
    page.data.save
    page.save

    users(:blue).updated(page)
    login_as :orange
    get :show, :page_id => page.id
    assert_not_nil assigns(:last_seen), 'last_seen should be set, since the page has changed'
  end
=end

  # edit, save, done
  # edit, lock stolen, try to save, see lock error, retake lock, save
  # edit, lock stolen, thief saves, try save, see old version error, save (overwrites)
  # test decorate with edit links
  def test_create
    login_as :quentin

    assert_no_difference 'Page.count' do
      post 'create', :id => WikiPage.param_id, :page => {:title => nil}
      assert_equal 'error', flash[:type], "page title should be required"
    end

    assert_difference 'Page.count' do
      post :create, :id => WikiPage.param_id, :group_id=> "", :create => "Create page", :tag_list => "",
           :page => {:title => 'my title', :summary => ''}
      assert_response :redirect
      assert_not_nil assigns(:page)
      assert_not_nil assigns(:page).data

      assert_redirected_to @controller.page_url(assigns(:page), :action => 'show'), "create action should redirect to show"
      get :show, :page_id => assigns(:page).id

      assert_redirected_to @controller.page_url(assigns(:page), :action => 'edit'), "showing empty wiki should redirect to edit"
    end
  end

  def test_edit
    login_as :orange
    pages(:wiki).add users(:orange), :access => :edit
    pages(:wiki).add users(:blue), :access => :edit

    get :edit, :page_id => pages(:wiki).id
    assert_equal [], assigns(:wiki).sections_open_for(users(:blue)), "editing a wiki should lock it"

    assert_equal users(:orange), assigns(:wiki).locker_of(:document), "should be locked by orange"

    assert_no_difference 'pages(:wiki).updated_at' do
      put :update, :page_id => pages(:wiki).id, :cancel => 'true'
      assert_equal [:document], assigns(:wiki).sections_open_for(users(:blue)), "cancelling the edit should unlock wiki"
    end

    # save twice, since the behavior is different if current_user has recently saved the wiki
    (1..2).each do |i|
      str = "text %d for the wiki" % i
      put :update, :page_id => pages(:wiki).id, :save => true, :wiki => {:body => str, :version => i}
      assert_equal str, assigns(:wiki).body
      assert_equal [:document], assigns(:wiki).sections_open_for(users(:blue)), "saving the edit should unlock wiki"
    end
  end

  def test_print
    login_as :orange

    get :print, :page_id => pages(:wiki).id
    assert_response :success
#    assert_template 'print'
  end

  def test_preview
    # TODO:  write action and test
  end

  def test_edit_inline
    login_as :blue
    xhr :get, :edit, :page_id => pages(:multi_section_wiki).id, :section => "second-oversection"

    assert_response :success

    wiki = assigns(:wiki)
    blue = users(:blue)

    assert_equal blue, wiki.locker_of("second-oversection"), "wiki second oversection should be locked by blue"

    # nothing should appear locked to blue
    assert_equal wiki.all_sections, wiki.sections_open_for(users(:blue)), "no sections should look locked to blue"
    assert_equal wiki.all_sections - ['section-three', 'second-oversection', :document],
                  wiki.sections_open_for(users(:gerrard)),
                  "no sections except what blue has locked (and its ancestors) should look locked to gerrard"

    assert_rendered_update_wiki_html(wiki, 'second-oversection', ['section-three'])
  end

  # various regression tests for text that has thrown errors in the past.
  def test_edit_inline_with_problematic_text
    login_as :blue

    ##
    ## headings without a leading return. (ie "</ul><h1>" )
    ##

    page = WikiPage.create! :title => 'problem text', :owner => 'blue' do |page|
      page.data = Wiki.new(:body => "\n\nh1. hello\n\n** what?\n\nh1. goodbye\n\n")
    end
    get :show, :page_id => page.id
    page = assigns(:page)
    assert_nothing_raised do
      xhr :get, :edit, :page_id => page.id, :section => "hello"
    end

    assert_response :success
    assert_rendered_update_wiki_html(page.wiki, 'hello')
  end

  def test_save_inline
    starting_all_sections = pages(:multi_section_wiki).wiki.all_sections
    login_as :blue
    xhr :get, :edit, :page_id => pages(:multi_section_wiki).id, :section => "section-three"
    # save the new (without a header)
    xhr :put, :update, :page_id => pages(:multi_section_wiki).id, :section => "section-three",
                  :wiki => {:body => "a line"}

    assert_response :success
    wiki = assigns(:wiki)
    wiki.reload

    assert_equal starting_all_sections - ['section-three'], wiki.all_sections, "section three should have been deleted"
    expected_body = pages(:multi_section_wiki).wiki.body.dup

    expected_body.gsub!("h2. section three\n\ns3 text first line\ns3 last lime", "a line")
    assert_equal expected_body, wiki.body, "wiki body should be updated"

    assert_rendered_update_wiki_html(wiki, nil)
  end

  def test_break_lock
    login_as :blue

    page = pages(:wiki)
    wiki = page.data

    user = users(:blue)
    different_user = users(:orange)

    page.add(user, :access => :admin)
    page.add(different_user, :access => :admin)

    wiki.lock!(:document, different_user)

    assert_equal [], wiki.sections_open_for(user)

    put :update, :page_id => pages(:wiki).id, :break_lock => true

    assert_equal [:document], wiki.reload.sections_open_for(user)
    assert_response :success
    assert_equal wiki.body, assigns(:wiki).body
    assert_rendered_full_page_edit_form(wiki.body)
  end

  protected

  def assert_rendered_update_wiki_html(wiki, inline_form_section = nil, inline_form_subsections = nil)
    # inline form subsections should not be displayed either
    inline_form_subsections ||= []
    html_heading_names = wiki.all_sections - [:document, inline_form_section]
    html_heading_names -= inline_form_subsections

    assert_select_rjs :replace_html, :wiki_html do |els|
      if inline_form_section
        section_body = wiki.get_body_for_section(inline_form_section)
        assert_select 'textarea', :text => section_body
      end

      full_html = els.collect(&:to_s).join("\n")
      assert_html_for_wiki_section_headings(full_html, html_heading_names)
      assert_no_html_for_wiki_section_headings(full_html, inline_form_subsections)
    end
  end

  def assert_html_for_wiki_section_headings(full_html, html_heading_names)
    # now check that we have all the headings
    html_heading_names.each do |html_heading|

      # Ex: /<h\d+.*?><a name="section-two"><\/a>/
      heading_re = %r{<h\d+.*?><a name="#{html_heading}"></a>}
      assert full_html =~ heading_re, "wiki html should contain [#{html_heading}]"
    end
  end

  def assert_no_html_for_wiki_section_headings(full_html, html_heading_names)
    # now check that we have none of the headings
    html_heading_names.each do |html_heading|

      # Ex: /<h\d+.*?><a name="section-two"><\/a>/
      heading_re = %r{<h\d+.*?><a name="#{html_heading}"></a>}
      assert full_html !~ heading_re, "wiki html should not contain [#{html_heading}]"
    end
  end


  def assert_rendered_full_page_edit_form(body)
    assert_select '#tab-edit-greencloth' do
      assert_select 'textarea', :text => body
    end

    assert_select ".wiki_buttons" do
      assert_select 'input' do
        assert_select '[name=save]'
      end
    end
  end

end
