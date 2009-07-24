module RequestsHelper

  def request_action_links(request)
    return unless  request.state == 'pending'

    links = []
    links << link_to('approve'.t, {:controller => '/requests', :action => 'approve', :id => request.id}, :method => :post)
    links << link_to('reject'.t, {:controller => '/requests', :action => 'reject', :id => request.id}, :method => :post)

    link_line(*links)
  end

  def request_state_links
    hash = {:controller => params[:controller], :action => params[:action]}
    hash[:id] = @group if @group

    link_line(
      link_to_active(:pending.t, hash.merge(:state => 'pending')),
      link_to_active(:approved.t, hash.merge(:state => 'approved')),
      link_to_active(:rejected.t, hash.merge(:state => 'rejected'))
    )
  end

  def request_tabs
    @info_box_class = 'tabs'
    hash = {:controller => params[:controller], :action => params[:action]}
    hash[:id] = @group if @group

    Formy.tabs do |f|
      f.tab do |t|
        t.label 'Pending'[:pending]
        t.url url_for(hash.merge(:state => 'pending'))
        t.selected params[:state] == 'pending'
      end
      f.tab do |t|
        t.label 'Approved'[:approved]
        t.url url_for(hash.merge(:state => 'approved'))
        t.selected params[:state] == 'approved'
      end
      f.tab do |t|
        t.label 'Rejected'[:rejected]
        t.url url_for(hash.merge(:state => 'rejected'))
        t.selected params[:state] == 'rejected'
      end
    end
  end

  def request_destroy_link(request)
    link_to('destroy'.t, {:controller => '/requests', :action => 'destroy', :id => request.id}, :method => :post)
  end

end
