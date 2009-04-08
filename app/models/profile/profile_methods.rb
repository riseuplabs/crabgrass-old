=begin

  a mix-in for Group and User associations with Profiles.
  TODO: filter on language too

=end

module ProfileMethods

  # returns the best profile for user to see
  def visible_by(user)
    if user
      profile = find_by_access(*(proxy_owner.relationships_to(user) + [:stranger]))
    else
      profile = find_by_access :stranger
    end
    return profile || Profile.new
  end

  # returns the first profile that matches one of the access symbols in *arg
  # in this order of precedence: foe, friend, peer, fof, stranger.
  def find_by_access(*args)
    args.map!{|i| if i==:member; :friend; else; i; end}
    conditions = args.collect{|access| "profiles.`#{access}` = ?"}.join(' OR ')
    find(
      :first,
      :conditions => [conditions]+[true]*args.size,
      :order => 'foe DESC, friend DESC, peer DESC, fof DESC, stranger DESC'
    )
    
  end
  
  # a shortcut to grab the 'public' profile
  def public
    @public_profile ||= (find_by_access(:stranger) || create_or_build(:stranger => true))
  end
  
  # a shortcut to grab the 'private' profile
  def private
    @private_profile ||= (find_by_access(:friend) || create(:friend => true))
  end
  
  def create_or_build(args={})
    if proxy_owner.new_record?
      build(args)
    else
      create(args)
    end
  end
  
end

