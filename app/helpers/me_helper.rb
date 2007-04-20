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


end
