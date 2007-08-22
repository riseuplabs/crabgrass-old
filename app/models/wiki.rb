
class Wiki < ActiveRecord::Base
  
  has_many :pages, :as => :data
  belongs_to :locked_by, :class_name => 'User', :foreign_key => 'locked_by_id'
  belongs_to :user
  
  acts_as_versioned :version_column => :lock_version
  self.non_versioned_columns << 'locked_by_id' << 'locked_at'
  
    # we do this so that we can access the page even before page or wiki are saved
  def page
    return pages.first if pages.any?
    return @page
  end
  def page=(p)
    @page = p
  end
  
  def version
    lock_version.to_i
  end
  
  #### LOCKING #######################
  
  LOCKING_PERIOD = 60.minutes

  def lock(time, locked_by)
    without_locking do
      without_revision do
        update_attributes(:locked_at => time, :locked_by => locked_by)
      end
    end
  end

  def unlock
    lock(nil,nil)
  end
   
  def lock_duration(time)
    ((time - locked_at) / 60).to_i unless locked_at.nil?
  end  
  
  def locked?(comparison_time=nil)
    comparison_time ||= Time.now
    locked_at + LOCKING_PERIOD > comparison_time unless locked_at.nil?
  end

  # returns true if the page is not locked by someone else
  def editable_by?(user)
    not locked? or locked_by == user
  end
  
  ##### VERSIONING #############################
  
  # returns true if the last version was created recently by this same author.
  def recent_edit_by?(author)
    (user == author) && (updated_at + 30.minutes > Time.now) if updated_at
  end 
  
  # returns first version since @time@
  def first_since(time)
     versions.find(
       :first,
       :conditions => ['updated_at <= ?', time.to_s(:db)],
       :order => 'updated_at DESC',
       :limit => 1)
  end

  ##### RENDERING #################################
  
  # lazy rendering of body_html:
  # the body_html is only rendered when it is requested
  # and if it doesn't exist already.
  def body_html
    html = read_attribute(:body_html)
    unless html
      html = format_wiki_text(body)
      update_attribute(:body_html,html)
    end
    return html    
  end
  
  def body=(value)
    write_attribute(:body, value)
    write_attribute(:body_html, format_wiki_text(value))
  end
  
  # clears the rendered html. this is called
  # when a group's name is changed or some other event happens
  # which might affect how the html is rendered by greencloth.
  # this only clears the primary group's wikis, which should be fine
  # because default_group_name just uses the primary group's name.
  def self.clear_all_html(group)
    Wiki.connection.execute("UPDATE wikis set wikis.body_html = NULL WHERE wikis.id IN (SELECT pages.data_id FROM pages WHERE pages.data_type='Wiki' and pages.group_id = #{group.id})")
  end
  
  protected 
    
  def default_group_name
    if page and page.group_name
      #.sub(/\+.*$/,'') # remove everything after +
      page.group_name
    else
      'page'
    end
  end
  
  def format_wiki_text(text)
    GreenCloth.new(text, default_group_name).to_html
  end
   
end
