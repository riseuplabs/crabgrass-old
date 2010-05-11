module RequestsHelper

  def request_action_links(request)
    return unless request.state == 'pending'
    if (request.votable? and request.may_vote?(current_user)) or (!request.votable? and request.may_approve?(current_user))
      request_approve_reject_links(request)
    elsif request.votes.count > 0
      request_votes_tally_info(request)
    end
  end

  def request_votes_tally_info(request)
    I18n.t(:request_votes_tally_info,
              :approved_count => request.votes.approved.count,
              :rejected_count => request.votes.rejected.count)
  end

  def request_approve_reject_links(request)
    links = []
    links << link_to(I18n.t(:approve), {:controller => '/requests', :action => 'approve', :id => request.id}, :method => :post)
    links << link_to(I18n.t(:reject), {:controller => '/requests', :action => 'reject', :id => request.id}, :method => :post)

    link_line(*links)
  end

  def request_state_links
    hash = {:controller => params[:controller], :action => params[:action]}
    hash[:id] = @group if @group

    link_line(
      link_to_active(I18n.t(:pending), hash.merge(:state => 'pending')),
      link_to_active(I18n.t(:approved), hash.merge(:state => 'approved')),
      link_to_active(I18n.t(:rejected), hash.merge(:state => 'rejected'))
    )
  end

  def request_destroy_link(request)
    link_to(I18n.t(:destroy), {:controller => '/requests', :action => 'destroy', :id => request.id}, :method => :post)
  end

  def request_description(request)
    # need special view help for some requests
    case request
    when RequestToRemoveUser
      request_to_remove_user_description(request)
    else
      request.description
    end
  end

  def request_to_remove_user_description(request)
    i18n_key = request.description_translation
    subs = request.description_translation_params
    tooltip_keys = request.description_tooltip_translations
    subs[:tooltip] = tooltip(I18n.t(tooltip_keys[:caption]), I18n.t(tooltip_keys[:content]))

    I18n.t(i18n_key, subs)
  end
end
