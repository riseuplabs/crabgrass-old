#
# These are used in order to help make it easier to decide which
# thing is selected (for example, when showing navigation lists)
#
module ControllerExtension::UrlIdentifiers

  def self.included(base)
    base.class_eval do
      helper_method :action?
      helper_method :controller?
      helper_method :id?
    end
  end

  # returns true if params[:action] matches one of the args.
  def action?(*actions)
    actions.include?(params[:action].to_sym)
  end

  # returns true if params[:controller] matches one of the args.
  def controller?(*controllers)
    controllers.each do |cntr|
      if cntr.is_a? String
        return true if cntr == controller_string
      elsif cntr.is_a? Symbol
        return true if cntr == controller_symbol
      end
    end
    return false
  end

  # returns true if params[:id] matches the id passed in
  # the arguments may include the id in the form of an integer,
  # string, or active record object.
  def id?(*ids)
    for obj in ids
      if obj.is_a?(ActiveRecord::Base)
        return true if obj.id == params[:id].to_i
      elsif obj.is_a?(Integer)
        return true if obj == params[:id].to_i
      elsif obj.is_a?(String)
        return true if obj == params[:id].to_s
      elsif obj.is_a?(Symbol)
        return true if obj.to_s == params[:id].to_s
      end
    end
    return false
  end

  private

  def controller_string
    @controller_string ||= params[:controller].to_s.gsub(/^\//, '')
  end

  def controller_symbol
    @controller_symbol ||= params[:controller].gsub(/^\//,'').gsub('/','_').to_sym
  end

end

