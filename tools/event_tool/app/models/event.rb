class Event < ActiveRecord::Base
  include GeoKit::Geocoders  # for geocoding

  before_save :save_latitude_and_longitude  # attempt to geocode address
  before_save :check_time_conversion
  before_validation {|event| state = @state_other if @state_other && (state == 'Other' || state.blank? ) }

  has_one :page, :as => :data
  format_attribute :description

  #has_many :user_participations, :through => :data, :foreign_key => 'page_id'
  #has_many :attendees, :class_name => 'User', :through => :user_participations, :source => 'user'
  has_many :invitations, :as => :invitable 
  has_many :rsvps
  has_many :attendees, :through => :rsvps, :source => :user
  belongs_to :host, :class_name => 'User'#, :foreign_key => 'host_id'
  delegate :allows?, :display_name, :to => :page

  validate :validates_date_range
  def validates_date_range
    return true if is_all_day?
    unless self.starts_at
      errors.add_to_base("Event must have a start time.")
    end
    if self.ends_at && self.starts_at > self.ends_at
      errors.add_to_base("Event start time must be before end time.")
    end
  end

  def save_latitude_and_longitude
    address = "#{self.address1},#{self.address2},#{self.city},#{self.state},#{self.postal_code},#{self.country}"
    location = GoogleGeocoder.geocode(address)
    coords = location.ll.scan(/[0-9\.\-\+]+/)
    if coords.length == 2
      self.longitude = coords[1]
      self.latitude = coords[0]
    else
      self.longitude = nil
      self.latitude = nil
    end
  end

  attr_accessor :state_other

  def to_local(time )
    TzTime.new(tz_time_zone.utc_to_local(time), TimeZone[time_zone] )
  end

  attr_writer :date_start
  attr_writer :date_end, :hour_start, :hour_end
  def date_start(format = '%Y-%m-%d')
    #@date_start ||= (page.starts_at.loc('%Y-%m-%d') if page && page.starts_at )
    tz_time_zone.utc_to_local(starts_at).loc(format) if starts_at 
    #tz_time_zone.utc_to_local(date_start_utc)
    #@date_start ||= (tz_time_zone.utc_to_local(page.starts_at).loc('%Y-%m-%d') if page && page.starts_at )
  end

  def date_end(format = '%Y-%m-%d' )
    #@date_end ||=( page.ends_at.loc('%Y-%m-%d') if page && page.ends_at )
    #@hour_end ||= ( page.ends_at.loc('%I:%M %p') if page && page.ends_at )
    tz_time_zone.utc_to_local(ends_at).loc(format) if ends_at 
  end

  def hour_start
    #@hour_start ||= ( page.starts_at.loc('%I:%M %p') if page && page.starts_at )
    tz_time_zone.utc_to_local(starts_at).loc('%I:%M %p') if starts_at
  end
  def hour_end
    #@hour_end ||= ( page.ends_at.loc('%I:%M %p') if page && page.ends_at )
    tz_time_zone.utc_to_local(ends_at).loc('%I:%M %p') if ends_at
  end

  def starts_at
    @date_start ||= (page.starts_at.loc('%Y-%m-%d') if page && page.starts_at )
    @hour_start ||= ( page.starts_at.loc('%I:%M %p') if page && page.starts_at )
    start = [@date_start, @hour_start].compact
    return if start.empty?
    Time.parse start.join(' ')
  end

  def ends_at
    @date_end ||=( page.ends_at.loc('%Y-%m-%d') if page && page.ends_at )
    @hour_end ||= ( page.ends_at.loc('%I:%M %p') if page && page.ends_at )
    end_time = [@date_end, @hour_end].compact
    return if end_time.empty?
    Time.parse end_time.join(' ')
  end

  def tz_time_zone
    time_zone ? TimeZone[time_zone] : TzTime.zone
  end

  protected

  def default_group_name
    if page and page.group_name
      page.group_name
    else
      'page'
    end
  end

  def check_time_conversion
    # greenchange_note: HACK: all day events will be put in as UTC
    # noon (note: there is no 'UTC' timezone available, so we are
    # going to use 'London' for zero GMT offset as a hack for now)
    # so that when viewed in calendars or lists, the events will
    # always show up on the appropriate day ie, St. Patrick's day
    # should always be on the 17th of March regardless of my frame
    # of reference.  Also, since we have a programmatic flag to
    # identify all day events, this hack can be removed / migrated
    # later to any required handling of all day events that might be
    # more complex on the fetching side.
    if is_all_day?
      @hour_start = "12:00"
      @hour_end = "12:00"
      self.time_zone = "London"
    end

    #return true if [ starts_at, ends_at].compact.empty?
    page_settings = {}
    page_settings[:starts_at] = TzTime.new( starts_at, tz_time_zone ).utc if starts_at
    page_settings[:ends_at] = TzTime.new( ends_at, tz_time_zone ).utc if ends_at
    @date_start, @date_end, @hour_start, @hour_end = nil, nil, nil, nil
    unless page_settings.values.compact.empty? || ( page.starts_at == page_settings[:starts_at] and page.ends_at == page_settings[:ends_at] )
      page.new_record? ? page.attributes = page_settings : page.update_attributes( page_settings )
    end
    
    true
  end

    
end
