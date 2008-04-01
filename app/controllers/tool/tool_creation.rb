module Tool::ToolCreation

  def create_new_page(page_class=nil)
    page_type = page_class || get_page_type
    Page.transaction do
      page = page_type.create params[:page].merge({:created_by_id => current_user.id})
      if page.valid?
        add_participants!(page, params)
        page.tag_with(params[:tag_list]) if params[:tag_list]
      end
      page
    end
  end

  protected

  def add_participants!(page, options={})
    users     = get_users
    if (group = get_group(options))
      page.add(group, :access => :admin)
      users += group.users if options[:announce]
    end
    users.uniq.each do |u|
      if u.member_of? group
        page.add(u)
      else
        page.add(u, :access=>:admin)
      end
    end
  end

  def get_groups
    [get_group(params)]
  end

  def get_group(options = {})
    return unless options[:group_name].any? or options[:group_id].any?
    if options[:group_name]
      return Group.get_by_name(options[:group_name]) || raise(Exception.new('no such group %s' % options[:group_name]))
    end
    Group.find_by_id(options[:group_id])
  end
  
  def get_users
    [current_user]    
  end
  
  def get_page_type
    raise Exception.new('page type required') unless params[:id]
    return Page.display_name_to_class(params[:id])
  end

end

