
require 'google_map_marker'
require 'calendar_dates/month_display.rb'
require 'calendar_dates/week.rb'

class EventPageController < BasePageController

  helper :date
  helper :event_time 

  append_before_filter :fetch_event
  before_filter :login_required, :only => ['set_event_description', 'create', 'edit', 'new', 'update']

  def index
    calendar
    render :action => :calendar
  end

  def day
    list
  end

  def week
    list
  end

  def month
    list
  end

  def calendar
    list
    @month_display = MonthDisplay.new(@date)
  end
=begin
  def show
    @page = EventPage.find params[:id]
    current_user.may! :view, @page
#    @user_participation= UserParticipation.find(:first, :conditions => {:page_id => @page.id, :user_id => current_user.id})  
#    if @user_participation.nil?
#      @user_participation = UserParticipation.new
#      @user_participation.user_id = current_user.id
#      @user_participation.page_id = @page.id
#      @user_participation.save
#    end    
    #@watchers = UserParticipation.find(:all, :conditions => {:page_id => @page.id, :watch => TRUE})  
    #@attendies =  UserParticipation.find(:all, :conditions => {:page_id => @page.id, :attend => TRUE})  

  end
=end
  def edit
    @page = EventPage.find params[:id]
    current_user.may! :edit, @page
  end
  
  def update
    @page = EventPage.find params[:id]
    current_user.may! :edit, @page
    @event = @page.data
    # greenchange_note: currently, you aren't able to change a group
    # if one has already been set during event creation
    
    @event.attributes = params[:page].delete(:page_data)
    @page.attributes = params[:page]
    @page.updated_by = current_user


    if @page.save and @event.save
      redirect_to(event_url(@page)) and return
    else
      message :object => @page
      render :action => 'edit' end
  end

  def new 
      return redirect_to(create_page_url(nil, :group => params[:group]))
    @page = EventPage.new :group_id => params[:group_id], :event => { :starts_at => (TzTime.now.at_midnight + 9.hours).utc, :ends_at => (TzTime.now.at_midnight + 17.hours).utc }, :public => true, :public_participate => true
    @event = @page.build_data(:time_zone => current_user.time_zone)
    @event.page = @page
  end

  def set_event_description
    @event.description =  params[:value]
    @event.save
    render :text => @event.description_html
  end

  def participate
    @user_participation = UserParticipation.find(:first, :conditions => {:page_id => @page.id, :user_id => current_user.id})
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
  
  def create
    @page_class = EventPage
    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?
      begin
        @event = Event.new(params[:event])
        unless @event.valid?
          flash_message_now :object => @event
          return
        end
        @page = @page_class.create!(params[:page].merge(
          :user => current_user,
          :share_with => params[:recipients],
          :access => params[:access],
          :data => @event
          ))
          # FIXME: not sure if this is the appropriate way of setting page
          # terms. Problem is @event gets saved before page is set. So page
          # terms have not been set so far.
          # This might also need to be fixed for Assets and ExternalVideos
          #
        @event.save
        redirect_to(page_url(@page))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
      end
    end
  end

  protected
  
  def fetch_event
    return true unless @page
    @page.data ||= ::Event.new(:description => 'new event', :page => @page)
    @event = @page.data
  end

  def setup_view
  end
  
  # set the right time format for the event
  def set_time (time)
    time
  end

  def authorized?
    if @page and ( params[:action] == 'set_event_description' or params[:action] == 'edit' or params[:action] == 'update' )
      return current_user.may?(:admin, @page)
    else
      return true
    end
  end

  def request_dates
      if params[:date]
        @date = params[:date].to_date
      else
        @date = Date.today
      end

      if action_name == 'week'
        start_date  = @date.beginning_of_week.beginning_of_day
        end_date    = @date.beginning_of_week.end_of_day + 6.days
      elsif action_name == 'day'
        start_date  = @date.beginning_of_day
        end_date    = @date.end_of_day
      else # month is the default
        start_date  = @date.beginning_of_month.beginning_of_day
        end_date    = @date.end_of_month.end_of_day
      end

      [start_date, end_date]
  end

  # returns array of events for the current user or group, depending on context
  def list
    @start_date, @end_date = request_dates

    if @group
      @events = Page.send( *context_finder(@group)).page_type(:event).occurs_between_dates(
        @start_date, @end_date
      ).find(:all, :order => "starts_at ASC")
    elsif @person || @me
      @person ||= @me
      @events = @person.pages.page_type(:event).occurs_between_dates(
        @start_date, @end_date
      ).find(:all, :order => "starts_at ASC")
    else
      @events = Page.allowed(current_user, :view).page_type(:event).occurs_between_dates(
        @start_date, @end_date
      ).find(:all, :order => "starts_at ASC")
    end

    @events.uniq!
  end
end
=begin

might have to include some of this...
  def create
    if @page.save
      add_participants!(@page, params)
      return redirect_to(event_url(@page))
    else
#      message :object => @page
 #     render :action => 'new'
    end
  end
=end
 
