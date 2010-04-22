class Committee < Group

  ##
  ## NAMING
  ##

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

  # called when the parent's name has change
  def parent_name_changed
    self.name = short_name
  end

  # committees clean up their names a little different to make sure the group's
  # name is part of the committee's name.
  def clean_names
    super
    t_name = read_attribute(:name)
    return unless t_name
    if parent
      name_without_parent = t_name.sub(/^#{parent.name}\+/,'').gsub('+','-')
      write_attribute(:name, parent.name + '+' + name_without_parent)
    else
      write_attribute(:name, t_name.gsub('+','-'))
    end
  end

  ##
  ## ORGANIZATIONAL
  ##

  private

  before_destroy :remove_from_parent
  def remove_from_parent
    parent.remove_committee!(self)
    true
  end

  def parent=(p)
    raise 'call group.add_committee! instead'
  end

  ##
  ## PERMISSIONS
  ##

  public

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

  def may_be_pestered_by!(user)
    if user.member_of?(self)
      true  # members may pester
    elsif user.member_of?(self.parent)
      true  # members of parents may pester
    elsif profile.may_see? and parent.profile.may_see_committees?
      true  # strangers may pester if they can see self, and parent thinks that is ok.
            # TODO: i think it would be better for us to ensure that if the parent forbits
            # seeing committee, that all the subcommittees just have may_see set to false.
    else
      false
    end
  end

end
