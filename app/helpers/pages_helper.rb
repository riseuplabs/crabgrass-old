module PagesHelper

  def my_work_pages_views
    [:work, :watched, :editor, :owner, :unread]
  end

  def my_work_view_settings
    my_work_pages_views.map do |view|
      {:name => view, :translation => title_key_for(view)}
    end
  end

  def all_pages_views
    [:public, :networks, :groups]
  end

  def all_view_settings
    all_pages_views.map do |view|
      {:name => view, :translation => title_key_for(view)}
    end
  end

  def title_key_for(view)
    ('view_'+view.to_s+'_pages_option').to_sym
  end

  def description_key_for(view)
    ('view_'+view.to_s+'_pages_description').to_sym
  end

  def view_settings
    if action?(:my_work)
      my_work_view_settings
    elsif action?(:all)
      all_view_settings
    elsif my_work_pages_views.include?(params[:view].to_sym)
      my_work_view_settings
    elsif all_pages_views.include?(params[:view].to_sym)
      all_view_settings
    end
  end

  def action_bar_settings
    { :select =>
            [ {:name => :all,
               :translation => :select_all,
               :function => checkboxes_subset_function(".page_check_box", ".page_check_box")},
              {:name => :none,
               :translation => :select_none,
               :function => checkboxes_subset_function(".page_check_box", "")},
              {:name => :unread,
               :translation => :select_unread,
               :function => checkboxes_subset_function(".page_check_box", "section.pages-info.unread .page_check_box")}],
      :mark =>
            [ {:name => :read, :translation => :read},
              {:name => :unread, :translation => :unread},
              {:name => :unwatched, :translation => :unwatched}],
      :view => view_settings }
  end

end
