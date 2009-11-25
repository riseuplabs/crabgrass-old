module PageHistoryHelper
  def description_for(page_history)
    build_description(page_history) || ""
  end

  def details_for(page_history)
    build_details(page_history) || ""
  end

  protected

  def build_details(page_history)
    case page_history
    when PageHistory::ChangeTitle then I18n.t(:page_history_details_change_title, :from => page_history.details.fetch(:from), :to => page_history.details.fetch(:to))
    end
  end

  def build_description(page_history)
    user_name = page_history.user.nil? ? "Unknown/Deleted" : page_history.user.display_name

    object_name = case page_history.object
    when Group then page_history.object.full_name
    when User then page_history.object.display_name
    else "Unknown/Deleted"
    end

    case page_history
    when PageHistory::PageCreated            then I18n.t(:page_history_user_created_page, :user_name => user_name)
    when PageHistory::ChangeTitle            then I18n.t(:page_history_change_title, :user_name => user_name)
    when PageHistory::AddStar                then I18n.t(:page_history_add_star, :user_name => user_name)
    when PageHistory::RemoveStar             then I18n.t(:page_history_remove_star, :user_name => user_name)
    when PageHistory::MakePublic             then I18n.t(:page_history_make_public, :user_name => user_name)
    when PageHistory::MakePrivate            then I18n.t(:page_history_make_private, :user_name => user_name)
    when PageHistory::Deleted                then I18n.t(:page_history_deleted_page, :user_name => user_name)
    when PageHistory::StartWatching          then I18n.t(:page_history_start_watching, :user_name => user_name)
    when PageHistory::StopWatching           then I18n.t(:page_history_stop_watching, :user_name => user_name)
    when PageHistory::UpdatedContent         then I18n.t(:page_history_updated_content, :user_name => user_name)
    when PageHistory::GrantGroupFullAccess   then I18n.t(:page_history_granted_group_full_access, :user_name => user_name, :object_name => object_name)
    when PageHistory::GrantGroupWriteAccess  then I18n.t(:page_history_granted_group_write_access, :user_name => user_name, :object_name => object_name)
    when PageHistory::GrantGroupReadAccess   then I18n.t(:page_history_granted_group_read_access, :user_name => user_name, :object_name => object_name)
    when PageHistory::RevokedGroupAccess     then I18n.t(:page_history_revoked_group_access, :user_name => user_name, :object_name => object_name)
    when PageHistory::GrantUserFullAccess    then I18n.t(:page_history_granted_user_full_access, :user_name => user_name, :object_name => object_name)
    when PageHistory::GrantUserWriteAccess   then I18n.t(:page_history_granted_user_write_access, :user_name => user_name, :object_name => object_name)
    when PageHistory::GrantUserReadAccess    then I18n.t(:page_history_granted_user_read_access, :user_name => user_name, :object_name => object_name)
    when PageHistory::RevokedUserAccess      then I18n.t(:page_history_revoked_user_access, :user_name => user_name, :object_name => object_name)
    when PageHistory::AddComment             then I18n.t(:page_history_added_comment, :user_name => user_name)
    when PageHistory::UpdateComment          then I18n.t(:page_history_updated_comment, :user_name => user_name)
    when PageHistory::DestroyComment         then I18n.t(:page_history_destroyed_comment, :user_name => user_name)
    end
  end
end
