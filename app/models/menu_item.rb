class MenuItem < ActiveRecord::Base

  before_create :set_position
  acts_as_tree :order => :position

  belongs_to :widget
  validates_presence_of :widget_id

  TYPES={
    I18n.t(:external_link_menu_item)=>:external,
    I18n.t(:local_link_menu_item)=>:local,
    I18n.t(:page_menu_item)=>:page,
    I18n.t(:tag_menu_item)=>:tag,
    I18n.t(:search_menu_item)=>:search
  }

  def may_have_children?
    widget.name == "MenuWidget" and self.parent == nil
  end

  protected

  def set_position
    if parent
      self.position = parent.children.count
    else
      self.position = widget.menu_items.roots.count
    end
  end
end
