## Add view inheritance to ActionController
## Adapted from these patches:
## http://dev.rubyonrails.org/ticket/7076

ActionController::Base.class_eval do

  def default_template_name(action_name = self.action_name, klass = self.class)
    if action_name && klass == self.class
      action_name = action_name.to_s
      if action_name.include?('/') && template_path_includes_controller?(action_name)
        action_name = strip_out_controller(action_name)
      end
    end
    if !klass.superclass.method_defined?(:controller_path) 
      return "#{self.controller_path}/#{action_name}" 
    end 
            
    template_name = "#{klass.controller_path}/#{action_name}" 
        
    if template_exists?(template_name) 
      return template_name 
    else 
      return default_template_name(action_name, klass.superclass) 
    end 
  end

end

ActionView::PartialTemplate.class_eval do

  private
  
  def partial_pieces(view, partial_path)
    if partial_path.include?('/')
      return File.dirname(partial_path), File.basename(partial_path)
    else
      return partial_controller_find(view, partial_path)
    end
  end

  def partial_controller_find(view, partial_path, klass = view.controller.class) 
    if view.finder.file_exists?("#{klass.controller_path}/_#{partial_path}")  
      return klass.controller_path, partial_path 
    elsif !klass.superclass.method_defined?(:controller_path)  
      # End of the inheritance line 
      return view.controller.class.controller_path, partial_path 
    else  
      return partial_controller_find(view, partial_path, klass.superclass)  
    end  
  end
   
end

