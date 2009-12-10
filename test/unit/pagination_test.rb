require File.dirname(__FILE__) + '/../test_helper'

class PaginationTest < Test::Unit::TestCase
  fixtures :users, :groups, :memberships, :relationships, :pages, :sites, :page_terms

  def test_tracking_most_views_in_days_pagination
    user = users(:blue)
    group = groups(:rainbow)

    # test parameters
    all_pages = (group.pages.reject{|p| p.deleted?}).uniq
    all_pages_ids = all_pages.collect(&:id)
    per_page = 5
    total_pagination_pages = (all_pages.size.to_f / per_page).ceil
    # add trackings
    all_pages.each_with_index do |page, index|
      # first page gets the most views
      # last page gets only 1 view
      # lets us test that pagination sorts them properly
      (all_pages.size - index).times do
        Tracking.insert_delayed(:current_user => user,
          :user => user,
          :group => group,
          :page => page,
          :action => :view,
          :time => Time.now - 2.days)
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

    assert_equal all_pages_ids.size, pages.total_entries
    assert_equal all_pages_ids[0, per_page], pages.collect(&:id).sort
    assert_equal total_pagination_pages, pages.total_pages
  end
end
