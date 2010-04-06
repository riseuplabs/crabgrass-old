##
## PAGE SHARING
##
#
# Handles the sharing and notification of pages
#
# share this page with a notice message to any number of recipients.
#
# if the recipient is a user name, then the message and the page show up in
# user's inbox, and optionally they are alerted via email.
#
# if the recipient is an email address, an email is sent to the address with a
# magic url that lets the recipient view the page by clicking on a link
# and using their email as the password.
#
# the sending user must have admin access to send to recipients
# who do not already have the ability to view the page.
#
# the recipient may be an entire group, in which case we grant access
# to the group and send emails to each user in the group.
#
# you cannot share to users/groups that you cannot pester, unless
# the page is private and they already have access.
#
class BasePage::ShareController < BasePage::SidebarController

  before_filter :login_required
  verify :xhr => true

  helper 'base_page/share', 'autocomplete'

  # display the share or notify popup via ajax
  def show
    render :partial => 'base_page/share/' + params[:name] + '_popup'
  end

  # there are three ways to submit the form:
  # (1) cancel button (params[:cancel]==true)
  # (2) add button or return in add field (params[:add]==true)
  # (3) share button (params[:share]==true)
  #
  # recipient(s) examples:
  # * when updating the form:
  #   {"recipient"=>{"name"=>"", "access"=>"admin"}}
  # * when submitting the form:
  #   {"recipients"=>{"aaron"=>{"access"=>"admin"},
  #    "the-true-levellers"=>{"access"=>"admin"}}
  #
  def update
    @success_msg = I18n.t(:shared_page_success)
    notify_or_share(:share)
  end

  # handles the notification with or without sharing
  def notify
    @success_msg = I18n.t(:notify_success)
    notify_or_share(:notify)
  end

  protected

  def notify_or_share(action)
    if params[:cancel]
      close_popup
    elsif params[:add]
      @recipients = []
      if params[:recipient] and params[:recipient][:name].any?
        recipients_names = params[:recipient][:name].strip.split(/[, ]/)
        recipients_names.each do |recipient_name|
          @recipients << find_recipient(recipient_name, action)
        end
        @recipients.compact!
      end
      render :partial => 'base_page/share/add_recipient', :locals => {:alter_access => action == :share}
    elsif (params[:share] || params[:notify]) and params[:recipients]
      options = params[:notification] || HashWithIndifferentAccess.new
      convert_checkbox_boolean(options)
      options[:mailer_options] = mailer_options()
      options[:send_notice] ||= params[:notify].any?

      current_user.share_page_with!(@page, params[:recipients], options)
      @page.save!
      flash_message_now :success => @success_msg

      close_popup
    else
      close_popup
    end
  end

  ##
  ## UI METHODS FOR THE SHARE & NOTIFY FORMS
  ##

  def close_popup
    render :template => 'base_page/reset_sidebar'
  end

  def show_error_message
    render :template => 'base_page/show_errors'
  end

  #
  # given a recipient name, we try to find an appriopriate user or group object.
  # a lot can go wrong: the name might not exist, you may not have permission, the user might
  # already have access, etc.
  #
  def find_recipient(recipient_name, action=:share)
    recipient_name.strip!
    return nil unless recipient_name.any?
    recipient = User.on(current_site).find_by_login(recipient_name) || Group.find_by_name(recipient_name)
    if recipient.nil?
      recipient_display = " (#{h(recipient_name)})";
      flash_message_now(:type => 'error',
        :title => I18n.t(:not_found) + recipient_display)
      return nil
    elsif !recipient.may_be_pestered_by?(current_user)
      flash_message_now(:type => 'error',
        :title => I18n.t(:share_pester_error, :name => recipient.name))
      return nil
    elsif @page
      upart = recipient.participations.find_by_page_id(@page.id)
      if upart && action == :share && !upart.access.nil?
        flash_message_now(:type => 'info',
          :title => I18n.t(:share_already_exists_error, :name => recipient.name))
        return nil
      elsif upart.nil? && action == :notify
        if !recipient.may?(:view, @page) and !may_share_page?
          flash_message_now(:type => 'error',
            :title => I18n.t(:notify_no_access_error, :name => recipient.name))
          return nil
        end
      end
    end
    return recipient
  end

  private

  def authorized?
    return true if @page.nil?
    if action?(:update)
      may_share_page?
    elsif action?(:notify)
      may_notify_page?
    elsif action?(:show, :auto_complete)
      true
    end
  end

  # convert {:checkbox => '1'} to {:checkbox => true}
  def convert_checkbox_boolean(hsh)
    hsh.each_pair do |key,val|
      if val == '0'
        hsh[key] = false
      elsif val == '1'
        hsh[key] = true
      end
    end
  end

end
