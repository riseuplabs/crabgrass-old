module CacheHelper

  def group_cache_key(group, options={})
    params.merge(:version => group.version, :updated_at => group.updated_at.to_i, :lang => session[:language_code], :path => nil, :authenticity_token => nil, :access => @access).merge(options)
  end

  def me_cache_key
    params.merge(:user_id => current_user.id, :version => current_user.version, :path => nil, :authenticity_token => nil)
  end

end

