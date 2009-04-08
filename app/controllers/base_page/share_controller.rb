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

#  verify :method => :post, :only => [:move]
  #include BasePageHelper
  #auto_complete_for :recipient, :name

  
  helper 'base_page', 'base_page/share'

=begin  
  def auto_complete_for_recipient_name
     # getting all friends or peers of the user
    @users = User.find(:all, :conditions => "login LIKE '%#{recipient_name}%' AND id IN (#{[current_user.contact_ids, current_user.peer_ids].flatten.uniq!.join(', ')})")
    @groups = Group.find(:all, :conditions => "name LIKE '%#{recipient_name}%' AND id IN (#{current_user.group_ids.join(', ')})")
   
    @all_users = User.find(:all)
    @all_users.select {|user| user.profiles.public.may_pester? }
    
   # @all_users = User.find(:all, :joins => :profiles, :group => "profiles.stranger HAVING profiles.stranger = true")
        
    @recipients = (@users + @groups + @all_users).uniq!
 
    @recipients = @recipients.select { |rcpt|
      (rcpt.name =~ Regexp.new(params[:recipient][:name]) ||
       rcpt.display_name =~ Regexp.new(params[:recipient][:name]))
    }
    
    render :partial => 'base_page/auto_complete/recipient'
  end
=end

  def auto_complete_for_recipient_name
    name_filter = params[:recipient][:name]
    if name_filter
      @recipients = User.find :all, :conditions => ["login LIKE ?", "#{name_filter}%"], :limit => 13
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
    #debugger
    if params[:cancel] || !params[:recipients]
      close_popup
    elsif params[:recipient] and params[:recipient][:name].any?
      # add one recipient to the list
      recipient_name = params[:recipient][:name].strip 
      @recipient = User.find_by_login(recipient_name) || Group.find_by_name(recipient_name)
      if @recipient.nil?
        flash_message :error => 'no such name'
      elsif !@recipient.may_be_pestered_by?(current_user)
        flash_message :error => 'you may not pester'
      end
      render :partial => 'base_page/share/add_recipient'
    else
      # recipients with options, that looks like
      # {:animals => [:grant_access => :view], :blue => [:grant_access => :admin]
      recipients_with_options = get_recipients_with_options(params[:recipients])

      options = {
        :message => params[:notification][:message_text],
        :send_emails => params[:notification][:send_emails],
        :send_via_email => params[:notification][:send_via_email],
        :send_via_textmessage => params[:notification][:send_via_textmessage],
        :send_via_chat => params[:notification][:send_via_chat],
        :send_only_with_encryption => params[:notification][:send_only_with_encryption],
        :send_to_inbox => params[:notification][:send_to_inbox],
        :mailer_options => mailer_options
      }
      # current_user.share_page_with!(@page, recipients, options)
      current_user.share_page_by_options!(@page, recipients_with_options, options)      
      @page.save!
      flash_message :success => "You successfully shared this page."[:shared_page_success]
      close_popup
    end
  end

  # handles the notification with or without sharing
  def notify
    share 
    return
  end
  
  protected

  ##
  ## UI METHODS FOR THE SHARE & NOTIFY FORMS
  ## 

  # given the params[:recipients] returns an options-hash for recipients
  def get_recipients_with_options(recipients_with_options)  
    options_with_recipients = {}
    recipients_with_options.each_pair do |recipient,options|
      if options.kind_of?(Hash)
        options_with_recipients[symbolize_options(options)] ||= []
        options_with_recipients[symbolize_options(options)] << recipient.sub(" ", "+")
      end
      @recipients ||= []
      @recipients << recipient
    end
    options_with_recipients   
  end

  
  def symbolize_options options
    return options unless options.respond_to?(:each)
    symbolized_options = {}
    options.each do |k,v|
      k.respond_to?(:to_sym) ? k = k.to_sym : k ;
      v.respond_to?(:to_sym) ? v = v.to_sym : v ;
      symbolized_options[k] = v
    end
    symbolized_options
  end

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

end
