module Groups::PermissionsHelper

  def publicly_visible_checkbox(list)
    list.checkbox do |cb|
      cb.label I18n.t(:group_publicly_visible, :group => @group.group_type)
      cb.input check_box(:profile, :may_see, :onclick => 'setClassVisibility(".details", this.checked)')
      cb.info I18n.t(:group_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def committee_publicly_visible_checkbox(list)
    list.checkbox(:class => 'details', :hide => !@profile.may_see?) do |cb|
      cb.label I18n.t(:committee_publicly_visible)
      cb.input check_box(:profile, :may_see_committees, :onclick => '')
      cb.info I18n.t(:committee_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def group_members_publicly_visible_checkbox(list)
    list.checkbox(:class => 'details', :hide => !@profile.may_see?) do |cb|
      cb.label I18n.t(:group_members_publicly_visible)
      cb.input check_box(:profile, :may_see_members, :onclick => '')
      cb.info I18n.t(:group_members_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def allow_membership_requests_checkbox(list)
    list.checkbox do |cb|
      cb.label I18n.t(:allow_membership_requests)
      cb.input check_box(:profile, :may_request_membership, :onclick => '')
      cb.info I18n.t(:may_request_membership_description)
    end
  end

  def open_membership_policy_checkbox(list)
    list.checkbox do |cb|
      cb.label I18n.t(:open_group)
      cb.input check_box(:profile, :membership_policy, {:onclick => ''}, Profile::MEMBERSHIP_POLICY[:open], Profile::MEMBERSHIP_POLICY[:approval])
      cb.info I18n.t(:open_group_description)
    end
  end

  def council_field(row)
    if @group.council_id
      row.input link_to_group(@group.council, :avatar => :small)
    else
      row.input link_to(I18n.t(:create_a_new_thing, :thing => I18n.t(:council).downcase), councils_url(:action => 'new'))
    end
    row.info help('council')
  end
end
