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
    when PageHistory::ChangeTitle then "From: \"{from}\" To: \"{to}\""[:page_history_details_change_title, {:from => page_history.details.fetch(:from), :to => page_history.details.fetch(:to)}] 
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
    when PageHistory::PageCreated            then "{user_name} has created the page"[:page_history_user_created_page, {:user_name => user_name}]
    when PageHistory::ChangeTitle            then "{user_name} has modified the page title"[:page_history_change_title, {:user_name => user_name}]
    when PageHistory::AddStar                then "{user_name} has added a star"[:page_history_add_star, {:user_name => user_name}]
    when PageHistory::RemoveStar             then "{user_name} has removed a star"[:page_history_remove_star, {:user_name => user_name}]
    when PageHistory::MakePublic             then "{user_name} has made the page public"[:page_history_make_public, {:user_name => user_name}]
    when PageHistory::MakePrivate            then "{user_name} has made unchecked the option to make the page public"[:page_history_make_private, {:user_name => user_name}]
    when PageHistory::Deleted                then "{user_name} has deleted the page"[:page_history_deleted_page, {:user_name => user_name}]
    when PageHistory::StartWatching          then "{user_name} has started watching this page"[:page_history_start_watching, {:user_name => user_name}]
    when PageHistory::StopWatching           then "{user_name} has stop watching this page"[:page_history_stop_watching, {:user_name => user_name}]
    when PageHistory::UpdatedContent         then "{user_name} has updated the page content"[:page_history_updated_content, {:user_name => user_name}]
    when PageHistory::GrantGroupFullAccess   then "{user_name} granted full access to the group {object_name}"[:page_history_granted_group_full_access, {:user_name => user_name, :object_name => object_name}]
    when PageHistory::GrantGroupWriteAccess  then "{user_name} granted write access to the group {object_name}"[:page_history_granted_group_write_access, {:user_name => user_name, :object_name => object_name}]
    when PageHistory::GrantGroupReadAccess   then "{user_name} granted read access to the group {object_name}"[:page_history_granted_group_read_access, {:user_name => user_name, :object_name => object_name}]
    when PageHistory::RevokedGroupAccess     then "{user_name} revoked access to the group {object_name}"[:page_history_revoked_group_access, {:user_name => user_name, :object_name => object_name}]
    when PageHistory::GrantUserFullAccess    then "{user_name} granted full access to the user {object_name}"[:page_history_granted_user_full_access, {:user_name => user_name, :object_name => object_name}]
    when PageHistory::GrantUserWriteAccess   then "{user_name} granted write access to the user {object_name}"[:page_history_granted_user_write_access, {:user_name => user_name, :object_name => object_name}]
    when PageHistory::GrantUserReadAccess    then "{user_name} granted read access to the user {object_name}"[:page_history_granted_user_read_access, {:user_name => user_name, :object_name => object_name}]
    when PageHistory::RevokedUserAccess      then "{user_name} revoked access to the user {object_name}"[:page_history_revoked_user_access, {:user_name => user_name, :object_name => object_name}]
    when PageHistory::AddComment             then "{user_name} added a comment"[:page_history_added_comment, {:user_name => user_name}]
    when PageHistory::UpdateComment          then "{user_name} updated a comment"[:page_history_updated_comment, {:user_name => user_name}]
    when PageHistory::DestroyComment         then "{user_name} destroyed a comment"[:page_history_destroyed_comment, {:user_name => user_name}]
    end
  end
end
