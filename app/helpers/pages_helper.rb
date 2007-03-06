module PagesHelper

  def page_type_options
    TOOLS.collect{|tool|[tool.tool_type,tool.to_s] unless tool.internal?}.compact
  end
  
end
