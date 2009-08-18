#
#
#
#

class Me::MessagesController < Me::BaseController

  helper 'messages'
  permissions 'messages'
  stylesheet 'messages'

  #
  # display a list of recent message activity
  #
  def index
    @activities = Activity.for_dashboard(current_user).find(:all, :conditions => ['activities.type IN (?)', ['PrivatePostActivity', 'MessageWallActivity']], :limit => 50, :order => 'created_at DESC')
  end

  protected

end

