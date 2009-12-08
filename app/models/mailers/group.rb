module Mailers::Group
  def group_destroyed_notification(recipient, group)
    setup_destroyed_email(recipient, group)
  end

  protected

  def setup_destroyed_email(recipient, group)
    # @user may be nil
    @user = group.destroyed_by
    @group = group
    @site = Site.current
    @recipients = "#{recipient.email}"

    email_sender = @site.try.email_sender ? @site.email_sender : Conf.email_sender
    domain = @site.try.domain ? @site.domain : Conf.domain

    @from = email_sender.gsub('$current_host', domain)

    @subject = I18n.t(:group_destroyed_subject,
                        :group_type => @group.group_type,
                        :group => @group.full_name,
                        :user => @user.try.display_name)

    @body[:group_type] = @group.group_type
    @body[:group] = @group.full_name
    # TODO: include this link in the email body and have a directory for destroyed groups
    @body[:destroyed_group_directory_url] = group_directory_url(:action => 'destroyed', :host => domain)
  end
end