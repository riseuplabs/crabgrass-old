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

  before_filter :login_required, :except => [:auto_complete]
  protect_from_forgery :except => [:auto_complete]
  verify :xhr => true

  helper 'base_page', 'base_page/share'
  permissions 'base_page/share'

  def auto_complete
    # i am searching by display_name only under protest. this is going to
    # make it s.l.o.w.
    filter = "#{params[:query]}%"
    recipients = Group.find(:all,
      :conditions => ["groups.name LIKE ? OR groups.full_name LIKE ?", filter, filter],
      :limit => 20)
    recipients += User.on(current_site).find(:all,
      :conditions => ["users.login LIKE ? OR users.display_name LIKE ?", filter, filter],
      :limit => 20)
    recipients = recipients.sort_by{|r|r.name}[0..19]
    render :json => {
      :query => params[:query],
      :suggestions => recipients.collect{|entity|display_on_two_lines(entity)},
      :data => recipients.collect{|r|r.avatar_id||0}
    }
  end
  
  # display the share popup via ajax
  def show_popup
    if params[:name] == 'share'
      render :template => 'base_page/share/show_share_popup'
    else
      render :template => 'base_page/share/show_notify_popup'
    end
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
    @success_msg ||= "You successfully shared this page."[:shared_page_success]
    if params[:cancel]
      close_popup
    elsif params[:add]
      @recipients = []
      if params[:recipient] and params[:recipient][:name].any?
        recipients_names = params[:recipient][:name].strip.split(/[, ]/)
        recipients_names.each do |recipient_name|
          @recipients << find_recipient(recipient_name)
        end
        @recipients.compact!
      end
      render :partial => 'base_page/share/add_recipient'
    elsif params[:share] and params[:recipients]
      options = params[:notification] || HashWithIndifferentAccess.new
      convert_checkbox_boolean(options)
      options[:mailer_options] = mailer_options()

      current_user.share_page_with!(@page, params[:recipients], options)
      @page.save!
      flash_message_now :success => @success_msg
      close_popup
    else
      render :text => 'no button was pressed', :status => :error
    end
  end

  # handles the notification with or without sharing
  def notify
    @success_msg = "You successfully sent notifications."[:notify_success]
    params[:share] = params[:notify] # act as if share button was pressed if notify pressed.
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

  prepend_before_filter :fetch_page
  def fetch_page
    if params[:page_id].any?
      @page = Page.find_by_id(params[:page_id])
      @upart = @page.participation_for_user(current_user)
    end
    true
  end

  def find_recipient(recipient_name)
    recipient_name.strip!
    return nil unless recipient_name.any?
    recipient = User.on(current_site).find_by_login(recipient_name) || Group.find_by_name(recipient_name)        
    if recipient.nil?
      flash_message_now(:error => 'no such name'[:no_such_name])
    elsif !recipient.may_be_pestered_by?(current_user)
      flash_message_now(:error => 'you may not pester'[:you_may_not_pester])
    elsif @page && (upart = recipient.participations.find_by_page_id(@page.id)) && !upart.access.nil?
      flash_message_now(:error => 'a participation for this user / group already exists'[:participation_already_exists])
    else
      return recipient
    end
    return nil
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

  # this should be in a helper somewhere, but i don't know how to generate 
  # json response in the view. 
  def display_on_two_lines(entity)
   "<em>%s</em>%s" % [entity.name, ('<br/>' + h(entity.display_name) if entity.display_name != entity.name)]
  end

end
