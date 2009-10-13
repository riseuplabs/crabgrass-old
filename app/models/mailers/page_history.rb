module Mailers::PageHistory
  def self.included(base)
    base.instance_eval do
      add_template_helper(PageHistoryHelper)
      add_template_helper(PageHelper)
      add_template_helper(UrlHelper)
    end
  end

  def send_watched_notification(user, page_history)
    @user                 = user
    @page_history         = page_history
    @site                 = page_history.page.site
    @subject              = "#{@site.title} : #{@page_history.page.title}"
    @body[:page_history]  = @page_history
    setup_watched_notification_email
  end

  def send_digest_pending_notifications(user, page, page_histories)
    @user                   = user
    @site                   = page.site
    @subject                = "#{@site.title} : #{page.title}"
    @body[:page]            = page
    @body[:page_histories]  = page_histories
    setup_watched_notification_email
  end

  protected

  def from_address
    @site.email_sender.gsub('$current_host', @site.domain) 
  end

  def setup_watched_notification_email
    @from                 = "#{from_address}" 
    @recipients           = "#{@user.email}" 
    @body[:site]          = @site
    @body[:user]          = @user
  end
end
