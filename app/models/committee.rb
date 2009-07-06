class Committee < Group
  before_destroy :eliminate_councilship
  
  def eliminate_councilship
    if g = Group.find(:first, :conditions => { :council_id => self.id })
      g.council_id = nil
      g.save!
    end
  end

  # NAMING
  # the name of a committee includes the name of the parent, 
  # so the committee names are unique. however, for display purposes
  # we want to just display the committee name without the parent name.
  
  # parent name + committee name
  def full_name
    read_attribute(:name)
  end
  # committee name without parent
  def short_name
    (read_attribute(:name)||'').sub(/^.*\+/,'')
  end
  
  # what we show to the user
  def display_name
    if read_attribute(:full_name).any?
      read_attribute(:full_name)
    else
      short_name
    end
  end

  #has_many :delegations, :dependent => :destroy
  #has_many :groups, :through => :delegations
  #def group()
  #  groups.first if groups.any?
  #end

  # called when the parent's name has change
  def parent_name_changed
    self.name = short_name
  end

  # custom name setter so that we can ensure that the parent's
  # name is part of the committee's name.
  def name=(str)
    if parent
      name_without_parent = str.sub(/^#{parent.name}\+/,'').gsub('+','-')
      write_attribute(:name, parent.name + '+' + name_without_parent)
    else
      write_attribute(:name, str.gsub('+','-'))
    end
  end
  alias_method :short_name=, :name=
  
  def parent=(p)
    raise 'call group.add_committee! instead'
  end

  # if user has +access+ to group, return true.
  # otherwise, raise PermissionDenied
  def has_access!(access, user)
    if access == :admin
      ok = user.member_of?(self) || self.parent.has_access?(:admin, user)
    elsif access == :edit
      ok = user.member_of?(self) || user.member_of?(self.parent_id) || self.parent.has_access?(:edit, user)
    elsif access == :view
      ok = user.member_of?(self) || user.member_of?(self.parent_id) || self.parent.has_access?(:admin, user) || profiles.visible_by(user).may_see?
    end
    ok or raise PermissionDenied.new
  end
  
  ##
  ## relationships to users
  ##

  def may_be_pestered_by!(user)
    super and parent.profiles.visible_by(user).may_see_committees?
  end
  
end
