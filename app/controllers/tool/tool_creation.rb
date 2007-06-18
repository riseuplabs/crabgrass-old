module Tool::ToolCreation

  def create_new_page
    groups    = get_groups
    users     = get_users
    page_type = get_page_type
    
    page = page_type.new params[:page].merge({:created_by_id => current_user.id})
    groups.each do |group|
      page.add(group, :access => ACCESS_ADMIN)
      users += group.users if params[:announce]
    end
    users.uniq.each do |u|
      if u.member_of? groups
        page.add(u)
      else
        page.add(u, :access=>ACCESS_ADMIN)
      end
    end
    page.tag_with(params[:tag_list]) if params[:tag_list]
    page
  end

  protected
  
  def get_groups
    if params[:group_name].any?
      group = Group.get_by_name params[:group_name]
      raise Exception.new('no such group %s' % params[:group_name]) if group.nil?
      [group]
    elsif params[:group_id].any?
      group = Group.find_by_id params[:group_id]
      raise Exception.new('no such group') if group.nil?
      [group]
    else
      []
    end
  end
  
  def get_users
    [current_user]    
  end
  
  def get_page_type
    raise Exception.new('page type required') unless params[:id]
    return get_tool_class( Page.display_name_to_class(params[:id]) )
  end

end

