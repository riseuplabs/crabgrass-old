class UserParticipationObserver < ActiveRecord::Observer

  def after_save(user_participation)
    PageHistory::StartWatching.create!(:user => User.current, :page => user_participation.page) if user_participation.start_watching?
    PageHistory::StopWatching.create!(:user => User.current, :page => user_participation.page) if user_participation.stop_watching?
  end
end
