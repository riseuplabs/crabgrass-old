module MeHelper

  def folder_icon(image)
    image = "folders/#{image}" unless image.match(/\//)
    image_tag(image, :size => "22x22")
  end
  
  def folder_link(text,path=nil,image=nil)
    if params[:action] == 'inbox'
      klass = ('selected' if params[:path].join('/').ends_with?(path)) || ''
    elsif path=='all'
      klass = 'selected'
    else
      klass = ''
    end
    
    text = folder_icon(image) + " " + text if image
    link_to text, url_for(:action => 'inbox', :path => path), :class => klass
  end

  def task_link(text, id, default=false)
    if default and params[:id].empty?
      selected = 'selected'
    else
      selected = id == params[:id] ? 'selected' : ''
    end
    url = url_for :controller => 'me', :action => 'tasks', :id => id
    link_to text, url, :class => "tasklink #{selected}"
  end
  
end
