=begin

  This is a generic versioned wiki, primarily used by the Tool::TextDoc,
  but also used directly sometimes by other classes (like for Group's
  landing page wiki's).

=end

class Wiki < ActiveRecord::Base

  belongs_to :locked_by, :class_name => 'User', :foreign_key => 'locked_by_id'
  belongs_to :user

  # a wiki can be used in multiple places: pages or profiles
  has_many :pages, :as => :data
  has_one :profile, :class_name => 'Profile::Profile'
  
  acts_as_versioned :version_column => :lock_version
  self.non_versioned_columns << 'locked_by_id' << 'locked_at'
    
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
     return nil unless time
     versions.find(
       :first,
       :conditions => ['updated_at <= ?', time.to_s(:db)],
       :order => 'updated_at DESC',
       :limit => 1)
  end

  def version
    lock_version.to_i
  end

  ##### SAVING ####################################
  
  # 
  # a smart update of the wiki, taking into account locking
  # and the last time the wiki was saved by the same person.
  #
  # tries to save, throws an exception if anything goes wrong.
  # possible exceptions:
  #   ActiveRecord::StaleObjectError
  #   ErrorMessage
  #
  
  def smart_save!(params)
    self.body = params[:body]
    if params[:version] and version > params[:version].to_i
      raise ErrorMessage.new("can't save your data, someone else has saved new changes first.")
    end
 
    unless params[:user] and params[:user].is_a? User
      raise ErrorMessage.new("User is required.")
    end
    
    unless editable_by?(params[:user])
      raise ErrorMessage.new("Cannot save your data, someone else has locked the page.")
    end

    if recent_edit_by?(params[:user])
      save_without_revision
      find_version(version).update_attributes(:body => body, :body_html => body_html, :updated_at => Time.now)
    else
      user = params[:user]
      save!
    end  
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
 
  # called internally
  def format_wiki_text(text)
    if text
      GreenCloth.new(text, default_group_name).to_html
    else
      "<p></p>"
    end
  end
 
  
  ##### RELATIONSHIP TO GROUPS ###################
  
  # clears the rendered html. this is called
  # when a group's name is changed or some other event happens
  # which might affect how the html is rendered by greencloth.
  # this only clears the primary group's wikis, which should be fine
  # because default_group_name just uses the primary group's name.
  def self.clear_all_html(group)
    # for wiki's owned by pages
    Wiki.connection.execute("UPDATE wikis set wikis.body_html = NULL WHERE wikis.id IN (SELECT pages.data_id FROM pages WHERE pages.data_type='Wiki' and pages.group_id = #{group.id.to_i})")
    # for wiki's owned by groups
    Wiki.connection.execute("UPDATE wikis set wikis.body_html = NULL WHERE wikis.id IN (SELECT profiles.wiki_id FROM profiles WHERE profiles.entity_id = #{group.id.to_i})")
  end
  
  def default_group_name
    if page and page.group_name
      #.sub(/\+.*$/,'') # remove everything after +
      page.group_name
    elsif profile
      profile.entity.name
    else
      'page'
    end
  end
  
  #### RELATIONSHIP TO PAGES ########
    
  # we do this so that we can access the page even before page or wiki are saved
  def page
    return pages.first if pages.any?
    return @page
  end
  def page=(p)
    @page = p
  end
  
end
