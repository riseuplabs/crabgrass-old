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
class BasePage::ShareController < ApplicationController

  before_filter :login_required, :except => [:auto_complete_for_recipient_name]
  protect_from_forgery :except => [:auto_complete_for_recipient_name]
 
  helper 'base_page', 'base_page/share'

  def auto_complete_for_recipient_name 
   name_filter = params[:recipient][:name]
    if name_filter
      @recipients = Group.find :all, :conditions => ["groups.name LIKE ?", "#{name_filter}%"], :limit => 20
      @recipients += User.find :all, :conditions => ["users.login LIKE ?", "#{name_filter}%"], :limit => 20
      @recipients = @recipients[0..19]
      render :partial => 'base_page/auto_complete/recipient'
    end
  end
  
  # display the share popup via ajax
  def show_popup
    if params[:name] == 'share'
      render :template => 'base_page/share/show_share_popup'
    else
      render :template => 'base_page/share/show_notify_popup'
    end
  end  
  
#  "recipient"=>{"name"=>"", "access"=>"admin"}, "recipients"=>{"aaron"=>{"access"=>"admin"}, "the-true-levellers"=>{"access"=>"admin"}}

  def update
    @success_msg ||= "You successfully shared this page."[:shared_page_success]
    # raise params[:recipients][:public_group_everyone_can_see].inspect
    if params[:cancel]
      close_popup
    elsif params[:recipient] and params[:recipient][:name].any?
      # add one recipient to the list
      recipient_name = params[:recipient][:name].strip 
      @recipient = User.find_by_login(recipient_name) || Group.find_by_name(recipient_name)
      
      if @recipient.nil?
        flash_message :error => 'no such name'[:no_such_name]
      elsif !@recipient.may_be_pestered_by?(current_user)
        flash_message :error => 'you may not pester'[:you_may_not_pester]
      elsif @recipient.participations.find_by_page_id(@page.id)
        flash_message :error => 'a participation for this user / group already exists'[:participation_already_exists]
      end
      render :partial => 'base_page/share/add_recipient'
    elsif params[:recipients]
      options = params[:notification] || {}
      convert_checkbox_boolean(options)
      options[:mailer_options] = mailer_options()

      current_user.share_page_with!(@page, params[:recipients], options)
      @page.save!
      flash_message :success => @success_msg
      close_popup
    else
      close_popup
    end
  end

  # handles the notification with or without sharing
  def notify
    @success_msg = "You successfully sent notifications."[:notify_success]
    update
  end
  
  protected

  ##
  ## UI METHODS FOR THE SHARE & NOTIFY FORMS
  ## 

  def close_popup
    render :template => 'base_page/reset_sidebar'
  end

  def show_error_message
    render :template => 'base_page/show_errors'
  end

  def authorized?
    current_user.may? :admin, @page
  end

  prepend_before_filter :fetch_page
  def fetch_page
    if params[:page_id]
      @page = Page.find_by_id(params[:page_id])
      @upart = @page.participation_for_user(current_user)
    end
    true
  end

  private

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
