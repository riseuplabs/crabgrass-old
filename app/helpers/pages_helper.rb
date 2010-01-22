module PagesHelper
  def my_work_view_settings
    [
      {:name => :my_work, :translation => :view_my_work_pages_option},
      {:name => :watched, :translation => :view_watched_pages_option},
      {:name => :editor, :translation => :view_editor_pages_option},
      {:name => :owner, :translation => :view_owner_pages_option},
      {:name => :unread, :translation => :view_unread_pages_option}
    ]
  end

  def all_view_settings
   [
     {:name => :public, :translation => :public},
     {:name => :networks, :translation => :networks},
     {:name => :groups, :translation => :groups}
    ]
  end

  def view_settings
    if @tab == :my_work
      my_work_view_settings
    elsif @tab == :all
      all_view_settings
    end
  end

  def action_bar_settings
    { :select =>
            [ {:name => :all,
               :translation => :select_all,
               :function => checkboxes_subset_function(".page_check", ".page_check")},
              {:name => :none,
               :translation => :select_none,
               :function => checkboxes_subset_function(".page_check", "")},
              {:name => :unread,
               :translation => :select_none,
               :function => checkboxes_subset_function(".page_check", "section.pages_info.unread .page_check")}],
      :mark =>
            [ {:name => :read, :translation => :read},
              {:name => :unread, :translation => :unread},
              {:name => :watched, :translation => :watched},
              {:name => :unwatched, :translation => :unwatched}],
      :view => view_options }
  end
end
