module Me::RequestsHelper

  def action_bar_mark_settings
    if params[:view] == 'from_me'
      [{:name => :destroy, :translation => :destroy}]
    else
      [ {:name => :approve, :translation => :approve},
        {:name => :reject, :translation => :reject},
        {:name => :ignore, :translation => :ignore}]
    end
  end

  def action_bar_settings
    # only render action bar for pending requests
    return nil unless action?(:index)
    { :select =>
            [ {:name => :all,
               :translation => :select_all,
               :function => checkboxes_subset_function(".request_check", ".request_check")},
              {:name => :none,
               :translation => :select_none,
               :function => checkboxes_subset_function(".request_check", "")}],
      :mark => action_bar_mark_settings,
      :view =>
            [ {:name => :to_me, :translation => :requests_to_me},
              {:name => :from_me, :translation => :requests_from_me}] }
  end
end
