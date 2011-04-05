class MenuItem < ActiveRecord::Base


  belongs_to :widget
  validates_presence_of :widget_id

  acts_as_tree :order => :position
  acts_as_list :scope => 'widget_id = #{self.widget_id} AND #{self.parent_condition}'

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

  def parent_condition
    parent ? "parent_id = #{parent.id}" : 'parent_id IS NULL'
  end

end
