=begin

  a mix-in for Group and User associations with Profiles.
  TODO: filter on language too

=end

module Profile::Methods

  # returns the best profile for user to see
  def visible_by(user)
    if user
      find_by_access(*(proxy_owner.relationships_to(user) + [:stranger]))
    else
      find_by_access :stranger
    end
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
    @public_profile ||= (find_by_access(:stranger) || create(:stranger => true))
  end
  
  # a shortcut to grab the 'private' profile
  def private
    @private_profile ||= (find_by_access(:friend) || create(:friend => true))
  end
  
end

