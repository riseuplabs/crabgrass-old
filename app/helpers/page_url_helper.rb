module PageUrlHelper

  def page_url_hash(page, options_override={})
    options = {}
    options[:controller] = "tool/" + page.controller
    options[:id] = page
    options[:action] = 'show'
    if params[:from]
      options[:from] = params[:from]
      options[:from_id] = params[:from_id]
    elsif ['groups','people','networks'].include? params[:controller]
      options[:from] = params[:controller]
      options[:from_id] = params[:id]
    elsif 'me' == params[:controller]
      options[:from] = 'people'
      options[:from_id] = current_user
    elsif page.groups.any?
      options[:from] = 'groups'
      options[:from_id] = page.groups.first.to_param
    elsif page.users.any?
      options[:from] = 'people'
      options[:from_id] = page.users.first.to_param
    end
    options.merge(options_override)
  end
  
  def page_url(page,options={})
    url_for page_url_hash(page,options)
  end
  
  def from_url(page=nil)
    ctr    = "/"+params[:from]
    id     = params[:from_id]
    action = 'show'
    if params[:from] == 'people' and params[:from_id] == current_user.to_param
      ctr = '/me'
      id = nil
      action = nil
    end
    url_for :controller => ctr, :id => id, :action => action
  end
  
end
