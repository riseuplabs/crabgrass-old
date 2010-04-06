#class YuckyController < ApplicationController
module ModerationNotice
  include  ActionView::Helpers::TextHelper # for truncate

  # Notify the admins that content has been marked as innapropriate
  def send_moderation_notice(url, summary)
    return if current_site.dev_email.empty?
    email_options = mailer_options.merge({:subject => I18n.t(:inappropriate_content), :body => summary, :url => url, :owner => current_user})
    admins = current_site.super_admin_group.users
    admins.each do |admin|
      AdminMailer.deliver_notify_inappropriate(admin, email_options)
    end
  end

end

