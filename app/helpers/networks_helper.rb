module NetworksHelper
  def create_network_link
    if logged_in?
      link_to_icon :create_a_new_thing.t % {:thing => 'network'.t}, 'actions/plus.png', :action => 'create'
    end
  end

end
