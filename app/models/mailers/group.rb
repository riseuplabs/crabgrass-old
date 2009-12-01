module Mailers::Group
  def group_destroyed_notification(recipient, group)
    setup_destroyed_email(recipient, group)
  end

  protected

  def setup_destroyed_email(recipient, group)
    @user = group.destroyed_by
    @group = group
    @site = Site.current || group.site
    @recipients = "#{recipient.email}"
    @from = @site.email_sender.gsub('$current_host', @site.domain)

    @subject = I18n.t(:group_destroyed_subject,
                        :group_type => @group.group_type,
                        :group => @group.full_name,
                        :user => @user.display_name)

    @body[:group_type] = @group.group_type
    @body[:group] = @group.full_name
    # TODO: include this link in the email body and have a directory for destroyed groups
    @body[:destroyed_group_directory_url] = group_directory_url(:action => 'destroyed', :host => @site.domain)
  end
end