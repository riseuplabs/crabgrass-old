module MeHelper

  include PageFinders
  
  def folder_icon(image)
    image = "folders/#{image}" unless image.match(/\//)
    image_tag(image, :size => "22x22")
  end
  
##moved folder_link to page_url_helper  

  def task_link(text, id, default=false)
    if default and params[:id].empty?
      selected = 'selected'
    else
      selected = id == params[:id] ? 'selected' : ''
    end
    url = url_for :controller => 'me', :action => 'tasks', :id => id
    link_to text, url, :class => "tasklink #{selected}"
  end
  
  def pending_request_link
    if @request_count == 1
      link_to @request_count.to_s + ' ' + 'pending request'.t, :controller => 'requests'
    elsif @request_count > 1
      link_to @request_count.to_s + ' ' + 'pending requests'.t, :controller => 'requests'
    end
  end
  
end
