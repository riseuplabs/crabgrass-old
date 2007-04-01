
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
  
  # returns true if the last version was created recently by this same author.
  def recent_edit_by?(author)
    (user == author) && (updated_at + 30.minutes > Time.now) if updated_at
  end 
  
  protected 
  
  def before_save
     self.body_html = format_wiki_text(body)
  end
  
  def default_group_name
    if page
      page.group_name || 'page'
    else
      'page'
    end
  end
  
  def format_wiki_text(text)
    GreenCloth.new(text, default_group_name).to_html
  end
   
end
