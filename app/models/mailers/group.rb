module Mailers::Group
  def group_destroyed_notification(user, group, options)
    setup(options)
    setup_destroyed_email(user, group)
  end

  protected

  def setup_destroyed_email(user, group)
    @user = user
    @group = group
    @recipients = "#{user.email}"
    @from = @site.email_sender.gsub('$current_host', @site.domain)

    @subject = I18n.t(:group_destroyed_subject,
                        :group_type => group.group_type,
                        :group => group.full_name,
                        :user => user.display_name)

    @body[:group_type] = group.group_type
    @body[:group] = group.full_name
    @body[:destroyed_group_directory_url] = group_directory_url(:action => 'destroyed')
  end
end