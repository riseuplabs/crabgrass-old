module RequestsHelper

  def request_action_links(request)
    return unless  request.state == 'pending'

    links = []
    links << link_to(I18n.t(:approve), {:controller => '/requests', :action => 'approve', :id => request.id}, :method => :post)
    links << link_to(I18n.t(:reject), {:controller => '/requests', :action => 'reject', :id => request.id}, :method => :post)

    link_line(*links)
  end

  def request_state_links
    hash = {:controller => params[:controller], :action => params[:action]}
    hash[:id] = @group if @group

    link_line(
      link_to_active(I18n.t(:pending), hash.merge(:state => 'pending')),
      link_to_active(I18n.t(:approved), hash.merge(:state => 'approved')),
      link_to_active(I18n.t(:rejected), hash.merge(:state => 'rejected'))
    )
  end

  def request_tabs
    @info_box_class = 'tabs'
    hash = {:controller => params[:controller], :action => params[:action]}
    hash[:id] = @group if @group

    Formy.tabs do |f|
      f.tab do |t|
        t.label I18n.t(:pending)
        t.url url_for(hash.merge(:state => 'pending'))
        t.selected params[:state] == 'pending'
      end
      f.tab do |t|
        t.label I18n.t(:approved)
        t.url url_for(hash.merge(:state => 'approved'))
        t.selected params[:state] == 'approved'
      end
      f.tab do |t|
        t.label I18n.t(:rejected)
        t.url url_for(hash.merge(:state => 'rejected'))
        t.selected params[:state] == 'rejected'
      end
    end
  end

  def request_destroy_link(request)
    link_to(I18n.t(:destroy), {:controller => '/requests', :action => 'destroy', :id => request.id}, :method => :post)
  end

end
