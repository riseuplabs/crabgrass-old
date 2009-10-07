module Mailers::PageHistory
  def self.included(base)
    base.instance_eval do
      add_template_helper(PageHistoryHelper)
      add_template_helper(PageHelper)
      add_template_helper(UrlHelper)
    end
  end

  def send_watched_notification(user, page_history)
    @user         = user
    @page_history = page_history
    @site         = page_history.page.site
    setup_watched_notification_email
  end

  protected

  def from_address
    @site.email_sender.gsub('$current_host', @site.domain) 
  end

  def setup_watched_notification_email
    @from                 = "#{from_address}" 
    @recipients           = "#{@user.email}" 
    @subject              = "#{@site.title} : #{@page_history.page.title}"
    @body[:site]          = @site
    @body[:user]          = @user
    @body[:page_history]  = @page_history
  end
end
