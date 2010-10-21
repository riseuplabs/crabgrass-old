#
# These are used in order to help make it easier to decide which
# thing is selected (for example, when showing navigation lists)
#
# for example:
#
#   active = controller?(:requests) and action?(:pending, :open)
#

module ControllerExtension::UrlIdentifiers

  def self.included(base)
    base.class_eval do
      helper_method :action?
      helper_method :controller?
      helper_method :id?
      helper_method :active_url?
      helper_method :url_active?
    end
  end

  ##
  ## PARAMS COMPARISON
  ##

  # returns true if params[:action] matches one of the args.
  def action?(*actions)
    actions.include?(params[:action].to_sym)
  end

  # returns true if params[:controller] matches one of the args.
  # for example:
  #   controller?(:me, :home)
  #   controller?('groups/')  <-- matches any controller in namespace 'groups'
  def controller?(*controllers)
    controllers.each do |cntr|
      if cntr.is_a? String
        if cntr.ends_with?('/')
          return true if controller_string.starts_with?(cntr.chop)
        end
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

  ##
  ## ACTIVE URL IDENTIFICATION
  ##

  # returns true if the current params matches url_hash
  def url_active?(url_hash)
    return false unless url_hash.is_a? Hash

    url_hash[:action] ||= 'index'

    selected = true
    url_hash.each do |key, value|
      selected = compare_param(params[key], value)
      break unless selected
    end
    selected
  end

  # here is another method to do the same thing. it is a bad sign when we start
  # to get duplicated efforts like this. I am not sure which one is better.
  # i moved both of them to this file to make it clear they are similar. -elijah

  def active_url?(url_path)
    if url_path.is_a?(String) or url_path.is_a?(Hash)
      url_for(url_path) =~ /^#{Regexp.escape(request.path)}$/i
    elsif url_path.is_a?(Array)
      !url_path.select { |path|
        url_for(path).match(/^#{Regexp.escape(request.path)}$/i) ? true : false
      }.empty?
    else
      false
    end
  end

  private

  def compare_param(a,b)
    a = a.to_param
    b = b.to_param
    if b.empty?
      true
    elsif a.empty?
      false
    elsif a == b
      true
    elsif a.is_a?(Array) or b.is_a?(Array)
      a = a.to_a.sort
      b = b.to_a.sort
      b == a
    elsif a.sub(/^\//, '') == b.sub(/^\//, '')
      true # a controller of '/groups' should match 'groups'
    else
      false
    end
  end

  def controller_string
    @controller_string ||= params[:controller].to_s.gsub(/^\//, '')
  end

  def controller_symbol
    @controller_symbol ||= params[:controller].gsub(/^\//,'').gsub('/','_').to_sym
  end

end

