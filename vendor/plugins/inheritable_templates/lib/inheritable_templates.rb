# encoding: UTF-8

module InheritableTemplates

  def self.template_exists?(controller, template_name)
    begin
      controller.view_paths.find_template(template_name, controller.send(:default_template_format))
      true
    rescue ActionView::MissingTemplate
      false
    end
  end

  # abstracts the process of finding an existing template up the controller inheritance chain
  def self.find_inherited_template(controller, template_basename)
    k = controller.class
    while (k = k.superclass) < ActionController::Base
      template_name = "#{k.controller_path}/#{template_basename}"
      return template_name if template_exists?(controller, template_name)
    end
  end

  # extends ActionController::Base
  module Controller
    def self.included base
      base.alias_method_chain :default_template_name, :inheritance
    end

    def default_template_name_with_inheritance(action_name = self.action_name)
      template_name = default_template_name_without_inheritance(action_name)
      return template_name if InheritableTemplates.template_exists?(self, template_name)
      InheritableTemplates.find_inherited_template(self, action_name) || template_name
    end
  end

  # extends ActionView::Partials
  module Partials
    def self.included base
      base.alias_method_chain :_pick_partial_template, :inheritance
    end

    def _pick_partial_template_with_inheritance(partial_path)
      path = case
      when partial_path.include?('/') then File.join(File.dirname(partial_path), "_#{File.basename(partial_path)}")
      when respond_to?(:controller) then
        InheritableTemplates.template_exists?(controller, p = "#{controller.class.controller_path}/_#{partial_path}") ?
          p : InheritableTemplates.find_inherited_template(controller, "_#{partial_path}")
      else "_#{partial_path}"
      end
      self.view_paths.find_template(path, self.template_format)
    end
  end

end
