require 'calendar_date_select'

class Tool::EventController < Tool::BaseController
  append_before_filter :fetch_event
  before_filter :login_required, :only => ['create', 'edit']
  
  #stylesheet 'event'
  
  def show
    @user_participation= UserParticipation.find(:first, :conditions => {:page_id => @page.id, :user_id => @current_user.id})  
    if @user_participation.nil?
      @user_participation = UserParticipation.new
      @user_participation.user_id = @current_user.id
      @user_participation.page_id = @page.id
      @user_participation.save
    end    
    @watchers = UserParticipation.find(:all, :conditions => {:page_id => @page.id, :watch => TRUE})  
    @attendies =  UserParticipation.find(:all, :conditions => {:page_id => @page.id, :attend => TRUE})  
  end

  def create
   @page_class = Tool::Event
   @event = ::Event.new   
    if request.post?
	    @page = build_new_page @page_class
	    @page.starts_at = params[:time_start]
	    @page.ends_at = params[:time_end]
	    @event = ::Event.new params[:event]
	    @page.data = @event
	    if @page.save
		   return redirect_to page_url(@page)
	    else
		    message :object => @page
	    end
    end
  end
 
 def set_event_description
   render:nothing => true
 end

 def participate
   @user_participation = UserParticipation.find(:first, :conditions => {:page_id => @page.id, :user_id => @current_user.id})
   if !params[:user_participation_watch].nil? 
     @user_participation.watch = params[:user_participation_watch]
     @user_participation.attend = false
   else
	   if !params[:user_participation_attend].nil?
	       @user_participation.watch = false
	       @user_participation.attend = params[:user_participation_attend]
	   else
		@user_participation.watch = false
		@user_participation.attend = false
		# remove the user participation from the table?
	   end
    end

   @user_participation.save
   render:nothing => true
 end
 
  protected

  def fetch_event
    return true unless @page
    @page.data ||= Event.new(:body => 'new page', :page => @page)
    @event = @page.data
  end
  
  def setup_view
    @show_attach = true
  end
  
  # set the right time format for the event
  def set_time (time)
	time
  end

end
