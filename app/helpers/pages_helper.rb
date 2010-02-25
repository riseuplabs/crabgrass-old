module PagesHelper

  def all_pages_views
    [:public, :networks, :groups]
  end

  def my_work_pages_views
    [:work, :watched, :editor, :owner, :unread]
  end

  #
  # All Pages Action
  #

  def all_pages_list
    render :partial => 'pages/list',
      :locals => {:with_notice => true, :full_width => true}
  end

  def all_pages_action_bar
  end

  def all_pages_settings
    { :view => all_view_settings }
  end

  def all_view_settings
    all_pages_views.map do |view|
      {:name => view, :translation => title_key_for(view)}
    end
  end

  #
  # My Work Action
  #

  def my_work_pages_list
    render :partial => 'pages/list',
      :locals => {:checkable => true, :with_notice => true, :full_width => true}
  end

  def my_work_action_bar
    render :partial => 'common/action_bar',
      :locals => {:settings => my_work_settings, :view_base_path => my_work_me_pages_path}
    action_bar_form(mark_me_pages_path, my_work_settings) do
      yield
    end
  end

  def my_work_hidden_fields
    render :partial => 'common/action_bar/hidden_form_fields',
      :locals => {:settings => my_work_settings}
  end

  def my_work_settings
    debugger
    { :select => my_work_select_settings,
      :mark => my_work_mark_settings,
      :view => my_work_view_settings }
  end

  def my_work_select_settings
    [ {:name => :all,
        :translation => :select_all,
        :function => checkboxes_subset_function(".page_check_box", ".page_check_box")},
      {:name => :none,
        :translation => :select_none,
        :function => checkboxes_subset_function(".page_check_box", "")},
      {:name => :unread,
        :translation => :select_unread,
        :function => checkboxes_subset_function(".page_check_box", "section.pages-info.unread .page_check_box")}]
  end

  def my_work_mark_settings
    [ {:name => :read, :translation => :read},
      {:name => :unread, :translation => :unread},
      {:name => :unwatched, :translation => :unwatched}]
  end

  def my_work_view_settings
    my_work_pages_views.map do |view|
      {:name => view, :translation => title_key_for(view)}
    end
  end

  #
  # General View and Translation Key Helpers
  #

  def title_and_info_for(view)
    render :partial => 'common/title_box',
      :locals => {:title => I18n.t(title_key_for(view))}
    render :partial => 'common/info_box',
      :locals => {:description => I18n.t(description_key_for(view))}
  end

  def title_key_for(view)
    ('view_'+view.to_s+'_pages_option').to_sym
  end

  def description_key_for(view)
    ('view_'+view.to_s+'_pages_description').to_sym
  end

end
