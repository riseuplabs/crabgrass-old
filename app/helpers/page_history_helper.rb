module PageHistoryHelper
  def description_for(page_history)
    build_description(page_history) || ""
  end

  def details_for(page_history)
    build_details(page_history) || ""
  end

  protected

  def build_details(page_history)
    case page_history.class.to_s
    when PageHistory::ChangeTitle.to_s            then I18n.t(:page_history_details_change_title, :from => page_history.details.fetch(:from), :to => page_history.details.fetch(:to))
    end
  end

  def build_description(page_history)
    user_name = page_history.user.display_name
    case page_history.class.to_s
    when PageHistory::PageCreated.to_s            then I18n.t(:page_history_user_created_page, :user_name => user_name)
    when PageHistory::ChangeTitle.to_s            then I18n.t(:page_history_change_title, :user_name => user_name)
    when PageHistory::AddStar.to_s                then I18n.t(:page_history_add_star, :user_name => user_name)
    when PageHistory::RemoveStar.to_s             then I18n.t(:page_history_remove_star, :user_name => user_name)
    when PageHistory::MakePublic.to_s             then I18n.t(:page_history_make_public, :user_name => user_name)
    when PageHistory::MakePrivate.to_s            then I18n.t(:page_history_make_private, :user_name => user_name)
    when PageHistory::Deleted.to_s                then I18n.t(:page_history_deleted_page, :user_name => user_name)
    when PageHistory::StartWatching.to_s          then I18n.t(:page_history_start_watching, :user_name => user_name)
    when PageHistory::StopWatching.to_s           then I18n.t(:page_history_stop_watching, :user_name => user_name)
    when PageHistory::UpdatedContent.to_s         then I18n.t(:page_history_updated_content, :user_name => user_name)
    when PageHistory::GrantGroupFullAccess.to_s   then I18n.t(:page_history_granted_group_full_access, :user_name => user_name, :object_name => page_history.object.full_name)
    when PageHistory::GrantGroupWriteAccess.to_s  then I18n.t(:page_history_granted_group_write_access, :user_name => user_name, :object_name => page_history.object.full_name)
    when PageHistory::GrantGroupReadAccess.to_s   then I18n.t(:page_history_granted_group_read_access, :user_name => user_name, :object_name => page_history.object.full_name)
    when PageHistory::RevokedGroupAccess.to_s     then I18n.t(:page_history_revoked_group_access, :user_name => user_name, :object_name => page_history.object.full_name)
    when PageHistory::GrantUserFullAccess.to_s    then I18n.t(:page_history_granted_user_full_access, :user_name => user_name, :object_name => page_history.object.display_name)
    when PageHistory::GrantUserWriteAccess.to_s   then I18n.t(:page_history_granted_user_write_access, :user_name => user_name, :object_name => page_history.object.display_name)
    when PageHistory::GrantUserReadAccess.to_s    then I18n.t(:page_history_granted_user_read_access, :user_name => user_name, :object_name => page_history.object.display_name)
    when PageHistory::RevokedUserAccess.to_s      then I18n.t(:page_history_revoked_user_access, :user_name => user_name, :object_name => page_history.object.display_name)
    when PageHistory::AddComment.to_s             then I18n.t(:page_history_added_comment, :user_name => user_name)
    when PageHistory::UpdateComment.to_s          then I18n.t(:page_history_updated_comment, :user_name => user_name)
    when PageHistory::DestroyComment.to_s         then I18n.t(:page_history_destroyed_comment, :user_name => user_name)
    end
  end
end
