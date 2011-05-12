class MenuItem < ActiveRecord::Base


  belongs_to :widget
  validates_presence_of :widget_id

  before_save :check_for_entity_links

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

  def check_for_entity_links
    case self.link
    when 'network_link', 'group_link'
      group = Group.find_by_name(self.title)
      group ||= Group.find_by_full_name(self.title)
      self.link = "/#{group.name}"
      self.title = group.display_name
    end
  end


end
