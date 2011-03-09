class GroupsController < Groups::BaseController
  # we display all students pages for teachers...
  def options_for_contributions
    options = {:select => "DISTINCT pages.*, user_participations.user_id, user_participations.changed_at"}
    if current_user.is_teacher?
      options.merge!({:conditions => ['user_participations.user_id IN (?)', current_user.students.collect{|s| s.id}.join(',')]})
    end
    options_for_mentor(options)
  end
end
