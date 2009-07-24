module DesignHelper

  def dummy_checkbox(id, text)
    checkbox_id = "checkbox_#{id}"
    checkbox_li_id = "checkbox_li_#{id}"
    checked = false;
    click = remote_function(
      :url => {:controller => 'design', :action => 'dummy_check'},
      :loading => hide(checkbox_id) + add_class_name(checkbox_li_id, 'check_spinning'),
      :complete => show(checkbox_id) + remove_class_name(checkbox_li_id, 'check_spinning')
    )
    out = []
    out << "<label id='#{checkbox_id}_label'>"
    out << check_box_tag(checkbox_id, '1', true, :class => 'check', :onclick => click)
    out << link_to(text, '#', :class => 'check')
    out << '</label>'
    out.join
  end

  def side_user_link(user)
    content_tag :li, user.display_name
  end

  def side_group_link(group)
    content_tag :li, group.display_name
  end

end

