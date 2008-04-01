module MyTasksHelper

  def task_link(text, options={})
    options[:selected] ||= options[:action]
    if options[:selected].to_a.include?(params[:action])
      selected = 'selected'
    else
      selected = ""
    end
    url = url_for :controller => 'my_tasks', :action => options[:action], :id => options[:id]
    link_to text, url, :class => "tasklink #{selected}"
  end

end
