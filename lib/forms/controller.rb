class Forms::Controller < ApplicationController
  layout "./forms/forms_layout" 
  before_filter :get_session_data, :except => :index
  after_filter :put_session_data, :except => :index
  skip_before_filter :login_required
  @@watching = {}
  @@last_page = nil
  
  def self.watch(object_map = {})
    @@watching = object_map
  end
  
  def self.pages(*page_list)
    @@pages = page_list
    @@last_page = page_list.last
  end

  def initialize
    @back_str      = _("<< <u>P</u>rev ")
    @forward_str   = _("<u>N</u>ext >>")
    @finish_str    = _("Finish")
    @startover_str = _("<< Start Over")  
  end

  # override the template name for subclasses 
  def default_template_name(action=self.action_name)
    "#{self.class.controller_path}_view"
  end
  
  def index
    # clear all the session data
    session['form_attributes'] = {}
    redirect_to :page => 'first'
  end
  
  def session_data(name)
    session['form_attributes'] ||= {} 
    session['form_attributes'][name.id2name] ||= {}
    session['form_attributes'][name.id2name]
  end
  
  def get_session_data
    @@watching.each do |object_name, class_constant|
      object = class_constant.new(session_data(object_name))
      object.define_pages(*@@pages)
      object.attributes = params[object_name] # merges attributes
      object.page = params[:page] if object.respond_to? :page=
      instance_variable_set("@#{object_name.id2name}", object);
    end
    @page = @params[:page]
    @forward = params[:commit] == @forward_str
    @back    = params[:commit] == @back_str
    @finish  = params[:commit] == @finish_str
    @form    = self.class.controller_name
    true
  end
  
  def put_session_data
    @@watching.each do |object_name, class_constant|
      object = instance_variable_get("@#{object_name.id2name}")
      data = session_data(object_name)
      data.replace(object.attributes)
    end
    true
  end
  
end
