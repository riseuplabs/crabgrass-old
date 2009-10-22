module PageHistoryHelper
  def description_for(page_history)
    description = build_description(page_history) || ""
    description.scan(/(\{\w+\.\w+\})/).flatten.each do |object_and_attribute|
      object, attribute = object_and_attribute.gsub(/\{|\}/, "").split(".")
      description.gsub!(object_and_attribute, page_history.send(object.to_sym).send(attribute.to_sym))
    end
    description
  end

  def description_with_links_for(page_history)
  end

  protected

  def build_description(page_history)
    case page_history.class.to_s
    when PageHistory::PageCreated.to_s            then "{user.display_name} has created the page"
    when PageHistory::ChangeTitle.to_s            then "{user.display_name} has modified the page title"
    when PageHistory::AddStar.to_s                then "{user.display_name} has added a star"
    when PageHistory::RemoveStar.to_s             then "{user.display_name} has removed a star"
    when PageHistory::MakePublic.to_s             then "{user.display_name} has made the page public"
    when PageHistory::MakePrivate.to_s            then "{user.display_name} has made unchecked the option to make the page public"
    when PageHistory::Deleted.to_s                then "{user.display_name} has deleted the page"
    when PageHistory::StartWatching.to_s          then "{user.display_name} has started watching this page"
    when PageHistory::StopWatching.to_s           then "{user.display_name} has stop watching this page"
    when PageHistory::UpdatedContent.to_s         then "{user.display_name} has updated the page content"
    when PageHistory::GrantGroupFullAccess.to_s   then "{user.display_name} granted full access to the group {object.full_name}"
    when PageHistory::GrantGroupWriteAccess.to_s  then "{user.display_name} granted write access to the group {object.full_name}"
    when PageHistory::GrantGroupReadAccess.to_s   then "{user.display_name} granted read access to the group {object.full_name}"
    when PageHistory::RevokedGroupAccess.to_s     then "{user.display_name} revoked access to the group {object.full_name}"
    when PageHistory::GrantUserFullAccess.to_s    then "{user.display_name} granted full access to the user {object.display_name}"
    when PageHistory::GrantUserWriteAccess.to_s   then "{user.display_name} granted write access to the user {object.display_name}"
    when PageHistory::GrantUserReadAccess.to_s    then "{user.display_name} granted read access to the user {object.display_name}"
    when PageHistory::RevokedUserAccess.to_s      then "{user.display_name} revoked access to the user {object.display_name}"
    when PageHistory::AddComment.to_s             then "{user.display_name} added a comment"
    when PageHistory::UpdateComment.to_s          then "{user.display_name} updated a comment"
    when PageHistory::DestroyComment.to_s         then "{user.display_name} destroyed a comment"
    end
  end
end
