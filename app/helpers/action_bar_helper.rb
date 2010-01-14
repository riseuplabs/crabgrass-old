module ActionBarHelper

  # target is :all, :none or :unread
  def select_function(target)

    uncheck_selector = selectors[:all]
    check_selector = selectors[target]

    # first, unselect all checkboxes
    # then, select target subset of checkboxes
    "toggleAllCheckboxes(false, '#{uncheck_selector}'); toggleAllCheckboxes(true, '#{check_selector}')"
  end

  def mark_function(as)
    "$('mark_as').value = '#{as}';this.up('form#mark_form').onsubmit()"
  end

  def view_filter_select
    options_hash={}
    views.each do |view|
      key = I18n.t("view_#{view}_#{controller.controller_name}_option".to_sym)
      options_hash[key] = view.to_s
    end
    options = options_for_select(options_hash, params[:view])
    select_tag 'view_filter_select', options
  end

end
