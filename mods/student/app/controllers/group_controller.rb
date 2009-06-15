class GroupController < ApplicationController
  def options_for_contributions
    options_for_mentor(:select => "DISTINCT pages.*, user_participations.user_id, user_participations.changed_at")
  end
end
