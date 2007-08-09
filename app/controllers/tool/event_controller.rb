require 'calendar_date_select'

class Tool::EventController < Tool::BaseController
  append_before_filter :fetch_event
  
  stylesheet 'event'
  
  def show
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

  def update
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
  
  # get a string and parse it into a location
  def set_location (location)	
	location_id =1
	location_id
  end
  
  # set the right time format for the event
  def set_time (time)
	time
  end

   def set_event_format (event, time_start, time_end, location)
	# event : title, description, time_start, time_end, is_all_day, is_cancelled, is_tentative, location_id, updated_at
	# > {"is_all_day"=>"0", "group_id"=>"2", "privacy_drop"=>"0", "location"=>"adsfadsf"}
	# NEEDS TO SETUP PRIVACY
	event_f = {}
	event_f["time_start"]= set_time time_start
	event_f["time_end"] = set_time time_end
	event_f["is_all_day"] = event["is_all_day"]
	event_f["is_cancelled"] = false
	event_f["location_id"] = set_location location
	event_f["updated_at"] = Time.now
	event_f
  end

end

