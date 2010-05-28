require File.dirname(__FILE__) + '/../test_helper'

class PageAccessTest < ActiveSupport::TestCase

  fixtures :pages, :users, :groups, :memberships

  def setup
  end

  def test_access_via_group
    user  = users(:red)
    group = groups(:rainbow)

    page = create_page :title => 'private page'

    assert !user.may?(:view, page), 'user should NOT be able to view page'
    page.add(group)
    assert user.may?(:view, page), 'user should BE able to view page'

    page.remove(group)
    page.reload
    user.clear_access_cache
    assert !user.may?(:view, page), 'user should NOT be able to view page'
  end

  def test_access_levels
    user  = users(:red)
    page = create_page :title => 'private page'

    assert !user.may?(:view, page), 'user should NOT have any access to the page'
    page.add(user, :access => :edit)
    assert user.may?(:view, page), 'user should be able to view page'
    assert user.may?(:edit, page), 'user should be able to edit page'
    assert !user.may?(:admin, page), 'user should be able to edit page'
  end

  def test_best_access
    user  = users(:red)
    group = groups(:rainbow)
    page = create_page :title => 'private page'
    page.add(group, :access => :admin)
    page.add(user, :access => :view)
    assert user.may?(:admin, page), 'user should be able to admin page'
  end

  protected

  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    Page.create(defaults.merge(options))
  end

end
