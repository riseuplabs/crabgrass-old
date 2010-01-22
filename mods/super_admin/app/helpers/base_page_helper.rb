module BasePageHelper

  def public_line
    if current_user.may?(:admin, @page)
      li_id = 'public_li'
      checkbox_id = 'public_checkbox'
      checked = @page.public? || @page.public_requested?
      url = {:controller => 'base_page/participation',:action => 'update_public', :page_id => @page.id, :public => (!checked).to_s}
      if !@page.public_requested?
        checkbox_line = sidebar_checkbox(I18n.t(:page_make_public_link), checked, url, li_id, checkbox_id, :title => I18n.t(:public_checkbox_help))
      elsif !@page.public?
        checkbox_line = sidebar_checkbox(I18n.t(:page_make_public_pending_link), checked, url, li_id, checkbox_id, :title => I18n.t(:public_checkbox_help))
      end
      content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
    end
  end

  def public_requested_line
    return 'public (pending)'
  end
end
