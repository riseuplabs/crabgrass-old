class MenuItem < ActiveRecord::Base

  # this is deprecated and will be removed soon.
  belongs_to :profile

  before_create :set_parent
  before_create :set_position
  acts_as_tree :order => :position

  belongs_to :widget
  validates_associated :widget

  TYPES={
    I18n.t(:external_link_menu_item)=>:external,
    I18n.t(:local_link_menu_item)=>:local,
    I18n.t(:page_menu_item)=>:page,
    I18n.t(:tag_menu_item)=>:tag,
    I18n.t(:search_menu_item)=>:search
  }

  protected

  def set_parent
    self.parent ||= widget.menu_items.root
  end

  def set_position
    if parent
      self.position = parent.children.count
    else
      self.position = widget.menu_items.roots.count
    end
  end

end
