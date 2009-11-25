module Groups::PermissionsHelper

  def admins_may_moderate_checkbox(list)
    list.checkbox(:class => 'council_details') do |cb|
      cb.label I18n.t(:admins_may_moderate, :group => @group.group_type)
      cb.input check_box(:profile, :admins_may_moderate)
      cb.info I18n.t(:admins_may_moderate_description, :domain => current_site.domain)
    end
  end
end
