module GalleryHelper
  def detail_view_navigation gallery, previous, this, after # next is reserved
    output  = '<div id="detail_view_navigation">'
    if previous && previous.kind_of?(ActiveRecord::Base)
      output << link_to(image_tag('icons/previous.png',
                                  :title => 'Previous'.t),
                        gallery_detail_view_url(gallery, previous))
    else
      output << '<span style="min-width:13px;width:13px;margin:1em;"></span>'
    end
    output << link_to(image_tag('pages/gallery.png',
                                :title => 'Back to gallery'.t),
                        page_url(gallery))
    if after && after.kind_of?(ActiveRecord::Base)
      output << link_to(image_tag('icons/next.png',
                                  :title => 'Next'.t),
                        gallery_detail_view_url(gallery, after))
    else 
      output << '<span style="min-width:13px;width:13px;margin:1em;"></span>'
    end
    output << '</div>'
    output
  end
  
  def gallery_detail_view_url gallery, image=nil
    url_for(:controller => 'gallery',
            :action => 'detail_view',
            :page_id => gallery.id,
            :id => (image ? image.id : nil))
  end
  
  def gallery_navigation *elements
    available_elements = { 
      :count => lambda {
        if @image_index
          "Image :image of :count".t%{
            :index => @image_index, :count => @image_count }
        else
          ":count Images".t%{ :count => @image_count }
        end
      },
      :formats => lambda { 
        # nothing here yet, code for the "Other Formats" link
        # (see https://we.riseup.net/assets/2644/Gallery+view.jpg)
      },
      :versions => lambda { 
        # code for "Past Versions", see above
      },
      :download => lambda { 
        if @image
          link_to(image_tag("actions/download.png")+"Download".t,
                  @image.url)
        else
          link_to(image_tag("actions/download.png")+"Download Gallery".t,
                  :controller => 'gallery',
                  :action => 'download_gallery',
                  :page_id => @page.id)
        end
      },
      :slideshow => lambda { 
        link_to("View Slideshow".t,
                :controller => 'gallery',
                :action => 'slideshow',
                :page_id => @page.id)
      },
      :edit => lambda { 
        if params[:action] == 'edit'
          link_to("Show Gallery".t,
                  :controller => 'gallery',
                  :action => 'show',
                  :page_id => @page.id)
        else
          link_to("Edit Gallery".t,
                  :controller => 'gallery',
                  :action => 'edit',
                  :page_id => @page.id)
        end
      }
    }
    
    output  = '<div id="gallery_navigation">'
    elements.each do |element|
      if available_elements[element]
        output << "<span>"+available_elements[element].call+"</span>"
      else
        raise ArgumentError.new("No such element: #{element}")
      end
    end
    output << '</div>'
    return output
  end
  
  def undo_remove_link(image_id, position)
    link_to_remote('undo',
                   :url => { 
                     :controller => 'gallery',
                     :action => 'add',
                     :page_id => @page.id,
                     :id => image_id,
                     :position => position
                   },
                   :success => "update_notifier('Successfully undeleted image.');undo_remove(#{image_id}, #{position});")
  end
  
  def gallery_delete_image(image, position)
    link_to_remote(image_tag('icons/small_png/cancel.png',
                             :title => 'Remove from gallery'),
                   :url => {
                     :controller => 'gallery',
                     :action => 'remove',
                     :page_id => @page.id,
                     :id => image.id,
                     :position => position
                   },
                   :update => 'gallery_notify_area',
                   :loading => "update_notifier('Removing image...', true);")
  end
  
  def gallery_move_image_without_js(image)
    output  = '<noscript>'
    output += link_to(image_tag('icons/small_png/left.png',
                                :title => 'Move image left'),
                      :controller => 'gallery',
                      :action => 'update_order',
                      :page_id => @page.id,
                      :id => image.id,
                      :direction => 'left')
    output += link_to(image_tag('icons/small_png/right.png',
                                :title => 'Move image right'),
                      :controller => 'gallery',
                      :action => 'update_order',
                      :page_id => @page.id,
                      :id => image.id,
                      :direction => 'right')
    output += '</noscript>'
    return output
  end
end
