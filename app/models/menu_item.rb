class MenuItem < ActiveRecord::Base

  belongs_to :profile
  acts_as_tree :order => :position

  belongs_to :widget

  TYPES={
    I18n.t(:external_link_menu_item)=>:external,
    I18n.t(:local_link_menu_item)=>:local,
    I18n.t(:page_menu_item)=>:page,
    I18n.t(:tag_menu_item)=>:tag,
    I18n.t(:search_menu_item)=>:search
  }

end
