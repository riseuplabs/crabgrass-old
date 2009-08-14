require File.dirname(__FILE__) + '/../test_helper'

class PaginationTest < Test::Unit::TestCase
  fixtures :users, :groups, :memberships, :relationships, :pages, :sites, :page_terms

  def test_tracking_most_views_in_days_pagination
    user = users(:blue)
    group = groups(:rainbow)

    # test parameters
    group_page_ids = (group.pages.reject{|p| p.deleted?}).collect(&:id).uniq.sort
    per_page = 5
    total_pages = (group_page_ids.size.to_f / per_page).ceil

    # add trackings
    group.pages.each do |page|
      3.times do
        Tracking.insert_delayed(:current_user => user, :user => user, :group => group, :page => page, :action => :view)
      end
    end

    Tracking.process
    Daily.update

    # pagination group options
    paginate_options = {
      :public => false,
      :callback => :options_for_group,
      :callback_arg_group => group,
      :user_ids => [user.id],
      :current_user => user,
      :group_ids => [group.id],
      :per_page => per_page,
      :page => 1}

    pages = Page.paginate_by_path(["most_views", "30", "days"], paginate_options)

    assert_equal group_page_ids.size, pages.size
    assert_equal group_page_ids[0, per_page], pages.collect(&:id).sort
    assert_equal total_pages, pages.total_pages
  end
end