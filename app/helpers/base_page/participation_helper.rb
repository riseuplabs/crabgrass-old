module BasePage::ParticipationHelper

  # we need to be careful not to trigger any extra queries with this helper,
  # since this could produce really bad load times.
  def show_or_edit_page_access(participation)
    if participation.is_a?(UserParticipation)
      part_id = {:upart_id => participation.id}
    else
      part_id = {:gpart_id => participation.id}
    end
    select_id = "access_select_#{participation.id}"
    display_access_icon(participation) + '&nbsp;' +
    if may_remove_participation?(participation)
      select_page_access(select_id, participation, {
        :remove => true,
        :onchange => remote_function(
          :url => {:controller => 'base_page/participation', :action => 'update', :page_id => @page.id}.merge(part_id),
          :loading => show_spinner(dom_id(participation)),
          :with => "'access='+$('#{select_id}').value"
        )
      })
    else
      display_access(participation)
    end
  end

  # shows a link to remove a user participation (called from _permissions.html.erb)
  def link_to_remove_user_participation(upart)
    if may_remove_participation?(upart)
      link_to_remote(I18n.t(:remove), :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :upart_id => upart.id}, :loading => show_spinner(dom_id(upart)), :complete => hide_spinner(dom_id(upart)) + resize_modal)
    end
  end

  # shows a link to remove a group participation (called from _permissions.html.erb)
  def link_to_remove_group_participation(gpart)
    if may_remove_participation?(gpart)
      link_to_remote(I18n.t(:remove), :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :gpart_id => gpart.id}, :loading => show_spinner(dom_id(gpart)), :complete => hide_spinner(dom_id(gpart)) + resize_modal)
    end
  end

  def select_page_owner
    if may_move_page?
      content_tag(:form,
        select_tag('owner_name',
          options_for_page_owner(:include_me => true, :selected => @page.owner_name),
          :onchange => 'this.form.submit();'
        ) + hidden_field_tag('authenticity_token', form_authenticity_token),
        :action => url_for(:controller => '/base_page/participation', :action => 'set_owner', :page_id => @page.id),
        :method => 'post'
      )
    elsif @page.owner
      h(@page.owner.both_names)
    else
      I18n.t(:none)
    end
  end

end

