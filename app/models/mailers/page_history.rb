module Mailers::PageHistory
  def self.included(base)
    base.instance_eval do
      add_template_helper(PageHistoryHelper)
      add_template_helper(PageHelper)
      add_template_helper(UrlHelper)
      add_template_helper(TimeHelper)
    end
  end

  def page_history_single_notification(user, page_history)
    @page_history         = page_history
    @user                 = user
    @site                 = page_history.page.site
    @subject              = "#{@site.title} : #{@page_history.page.title}"
    @body[:page_history]  = @page_history
    setup_watched_notification_email
  end

  def page_history_single_notification_paranoid(user, page_history)
    @page_history         = page_history
    @user                 = user
    @site                 = page_history.page.site
    @subject              = I18n.t(:page_history_mailer_a_page_has_been_modified, :site_title => @site.title)
    @body[:page_history]  = @page_history

    @body[:code] = Code.create!(:user => user, :page => page_history.page)

    setup_watched_notification_email
  end

  def page_history_digest_notification(user, page, page_histories)
    @site                   = page.site
    @user                   = user
    @subject                = "#{@site.title} : #{page.title}"
    @body[:page]            = page
    @body[:page_histories]  = page_histories
    setup_watched_notification_email
  end

  def page_history_digest_notification_paranoid(user, page, page_histories)
    @site                   = page.site
    @user                   = user
    @subject                = I18n.t(:page_history_mailer_a_page_has_been_modified, :site_title => @site.title)
    @body[:page]            = page
    @body[:page_histories]  = page_histories

    @body[:code] = Code.create!(:user => user, :page => page)

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
