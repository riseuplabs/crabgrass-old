class EventPageController < BasePageController
  append_before_filter :fetch_event
  
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

#  def edit

#  end

#  def update
#    @page.attributes = params[:page]
#    @event.attributes = params[:event]
#    if @page.save and @event.save
#      return redirect_to(page_url(@page))
#    else
#      flash_message_now :object => @page
#    end
#  end
 
 def create
    @page_class = EventPage
    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?
      begin
        if params[:event][:is_all_day]
          params[:hour_start] = "09:00"
          params[:hour_end] = "17:00"
          params[:date_end] = params[:date_start]
        end  
        d = params[:date_start].split("/")
        params[:date_start] = [d[1], d[0], d[2]].join("/")
        params[:time_start] =  params[:date_start] + " "+ params[:hour_start]
        d = params[:date_end].split("/")
        params[:date_end] = [d[1], d[0], d[2]].join("/")
        params[:time_end] =  params[:date_end] + " " + params[:hour_end]
      
        @event = Event.new(params[:event])
        unless @event.valid?
          flash_message_now :object => @event
          return
        end
        @page = @page_class.create!(params[:page].merge(
          :user => current_user,
          :share_with => params[:recipients],
          :access => params[:access],
          :data => @event,
          :starts_at  => Time.zone.local_to_utc(params[:time_start].to_time),
          :ends_at => Time.zone.local_to_utc(params[:time_end].to_time)
          ))
        redirect_to(page_url(@page))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
      end
    else
      @page = build_new_page(@page_class)
    end
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

   @watchers = UserParticipation.find(:all, :conditions => {:page_id => @page.id, :watch => TRUE})
   @attendies =  UserParticipation.find(:all, :conditions => {:page_id => @page.id, :attend => TRUE})
 end
 
  protected

  def fetch_event
    return true unless @page
    #@page.data ||= Event.new(:body => 'new page', :page => @page)
    @event = @page.data
  end
  
  def setup_view
    @show_attach = true
  end
  
  # set the right time format for the event
  def set_time (time)
    time
  end

  def authorized?
    if params[:action] == 'set_event_description' or params[:action] == 'edit'
      return current_user.may?(:admin, @page)
    else
      return true
    end
  end
end
