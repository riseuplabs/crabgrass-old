module Me::RequestsHelper
  def action_bar_settings
    { :select =>
            [ {:name => :all,
               :translation => :select_all,
               :function => checkboxes_subset_function(".request_check", ".request_check")},
              {:name => :none,
               :translation => :select_none,
               :function => checkboxes_subset_function(".request_check", "")}],
      :mark =>
            [ {:name => :approve, :translation => :approve},
              {:name => :reject, :translation => :reject},
              {:name => :ignore, :translation => :ignore}],
      :view =>
            [ {:name => :to_me, :translation => :requests_to_me},
              {:name => :from_me, :translation => :requests_from_me}] }
  end
end
