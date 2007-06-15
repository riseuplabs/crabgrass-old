class Committee < Group
  alias :group :parent
  alias :group= :parent=

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
    read_attribute(:name).sub(/^.*\+/,'')
  end
  # what we show to the user
  def display_name
    read_attribute(:display_name) || short_name
  end
        
  #has_many :delegations, :dependent => :destroy
  #has_many :groups, :through => :delegations
  #def group()
  #  groups.first if groups.any?
  #end

  # called when the parent's name has change
  def update_name
    new_name = parent.name + '+' + short_name
    update_attribute(:name, new_name) if new_name != full_name
  end
  
  protected
  
  def before_save
    if parent
      name_without_parent = full_name.sub(/^#{parent.name}\+/,'').gsub('+','-')
      write_attribute(:name, parent.name + '+' + name_without_parent)
    else
      write_attribute(:name, full_name.gsub('+','-'))
    end
  end

end
