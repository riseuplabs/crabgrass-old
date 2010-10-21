module Group::SearchHelper

  protected

  def toggle_selection_link
    link_to_function I18n.t(:toggle_selection),
      "$$('.page_check_box').each(function(cb) {cb.checked = !cb.checked})"
  end

  def undelete_from_trash_link
    submit_link I18n.t(:undelete_from_trash),
      :name => 'undelete'
  end

  def destroy_page_link
    submit_link I18n.t(:destroy_page_via_shred),
      :name => 'remove',
      :confirm => I18n.t(:destroy_confirmation, :thing => I18n.t(:page))
  end

end
