#class YuckyController < ApplicationController
module ModerationNotice
  include  ActionView::Helpers::TextHelper # for truncate

  permissions 'admin/moderation'
  permissions 'posts'

  before_filter :login_required

  protected

  # Notify the admins that content has been marked as innapropriate
  def send_moderation_notice(url, summary)
    email_options = mailer_options.merge({:subject => "Inappropriate content".t, :body => summary, :url => url, :owner => current_user})
    admins = current_site.super_admin_group.users
    admins.each do |admin|
      AdminMailer.deliver_notify_inappropriate(admin, email_options)
    end
  end

  def authorized?
    @rateable.created_by != current_user
  end

end

