module Me::TrashHelper

  def update_me_trash_path
    url_for :controller => :trash, :action => :update
  end

  def action_bar_settings
    { :select =>
            [ {:name => :all,
               :translation => :select_all,
               :function => checkboxes_subset_function(".page_check", ".page_check")},
              {:name => :none,
               :translation => :select_none,
               :function => checkboxes_subset_function(".page_check", "")}],
      :mark =>
            [ {:name => :read, :translation => :read},
              {:name => :unread, :translation => :unread},
              {:name => :unwatched, :translation => :unwatched}]
     }
  end
end
