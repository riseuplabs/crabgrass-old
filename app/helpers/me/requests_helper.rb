module Me::RequestsHelper

  def action_bar_view_base_path
    if action?(:index, :mark)
      requests_path
    else
      url_for(:controller => params[:controller], :action => params[:action])
    end
  end

  def action_bar_settings
    if action?(:index, :mark)
      action_bar_index_settings
    else
      action_bar_other_actions_settings
    end
  end

  ###
  ### index and mark actions
  ###
  def action_bar_index_mark_settings
    if params[:view] == 'from_me'
      [{:name => :destroy, :translation => :destroy}]
    else
      [ {:name => :approve, :translation => :approve},
        {:name => :reject, :translation => :reject},
        {:name => :ignore, :translation => :ignore}]
    end
  end

  def action_bar_index_settings
    # only render action bar for all lists of requests
    { :select =>
            [ {:name => :all,
               :translation => :select_all,
               :function => checkboxes_subset_function(".request_check", ".request_check")},
              {:name => :none,
               :translation => :select_none,
               :function => checkboxes_subset_function(".request_check", "")}],
      :mark => action_bar_index_mark_settings,
      :view =>
            [ {:name => :to_me, :translation => :requests_to_me},
              {:name => :from_me, :translation => :requests_from_me}] }
  end

  ###
  ### other actions
  ###
  def action_bar_other_actions_settings
    { :select => nil,
      :mark => nil,
      :view => [{:name => :all, :translation => :all},
                {:name => :to_me, :translation => :requests_to_me},
                {:name => :from_me, :translation => :requests_from_me}]
    }
  end
end
