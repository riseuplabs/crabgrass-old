class Committee < Group
  
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
    read_attribute(:display_name) || short_name
  end
        
  #has_many :delegations, :dependent => :destroy
  #has_many :groups, :through => :delegations
  #def group()
  #  groups.first if groups.any?
  #end

  # called when the parent's name has change
  def parent_name_change
    name = short_name
    update_attribute(:name, name)
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
  
  # custom setter so that we can ensure that the the committee's
  # name includes the parent's name.
  def parent=(p)
    update_attribute(:parent_id, p.id)
    parent_name_change
  end
 
  
end
