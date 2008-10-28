module WallHelper
  def private_corner_link user
    link_to("Private Corner", :controller => 'person', :action => 'show', :id => user.id, :wall => 'private')
  end
end
