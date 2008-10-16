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
          "Image :number of :count"[:image_count]%{
            :number => @image_index.to_s, :count => @image_count.to_s }
        else
          ":count Images"[:image_count_total] %{ :count => @image_count.to_s }
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
          link_to(image_tag("actions/download.png")+"Download"[:download],
                  @image.url)
        else
          link_to(image_tag("actions/download.png")+"Download Gallery"[:download_gallery],
                  page_url(@page, :action => 'download'))
        end
      },
      :slideshow => lambda { 
        link_to("View Slideshow"[:view_slideshow],
                page_url(@page, :action => 'slideshow'),
                :target => '_blank')
      },
      :edit => lambda { 
        unless params[:action] == 'edit'
          link_to("Edit Gallery"[:edit_gallery],
                  page_url(@page, :action => 'edit'))
        else
          available_elements[:show].call
        end
      },
      :show => lambda { 
        link_to("Show Gallery"[:show_gallery],
                page_url(@page))
      },
      :upload => lambda { 
                javascript_tag("target = document.createElement('div');
                                 target.id = 'target_for_upload';
                                 target.hide();
                                 $$('body').first().appendChild(target);")+
        spinner('show_upload')+
                link_to_remote("Upload Images"[:upload_images],
                                :url => page_url(@page, :action => 'upload'),
                                :update => 'target_for_upload', :loading =>'$(\'show_upload_spinner\').show();', :success => 'target.show();', :complete => '$(\'show_upload_spinner\').hide();')
        #link_to("Upload Images"[:upload_images],
        #        page_url(@page, :action => 'upload'))
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
    link_to_remote('undo'[:undo],
                   :url => { 
                     :controller => 'gallery',
                     :action => 'add',
                     :page_id => @page.id,
                     :id => image_id,
                     :position => position
                   },
                   :success => "update_notifier(#{'Successfully undeleted image.'[:successful_undelete_image]});undo_remove(#{image_id}, #{position});")
  end
  
  def gallery_delete_image(image, position)
    link_to_remote(image_tag('icons/small_png/cancel.png',
                             :title => 'Remove from gallery'[:remove_from_gallery]),
                   :url => {
                     :controller => 'gallery',
                     :action => 'remove',
                     :page_id => @page.id,
                     :id => image.id,
                     :position => position
                   },
                   :update => 'gallery_notify_area',
                   :loading => "update_notifier(#{'Removing image...'[:removing_image]}, true);")
  end
  
  def gallery_move_image_without_js(image)
    output  = '<noscript>'
    output += link_to(image_tag('icons/small_png/left.png',
                                :title => 'Move image left'[:move_image_left]),
                      :controller => 'gallery',
                      :action => 'update_order',
                      :page_id => @page.id,
                      :id => image.id,
                      :direction => 'left')
    output += link_to(image_tag('icons/small_png/right.png',
                                :title => 'Move image right'[:move_image_right]),
                      :controller => 'gallery',
                      :action => 'update_order',
                      :page_id => @page.id,
                      :id => image.id,
                      :direction => 'right')
    output += '</noscript>'
    return output
  end
  
  def js_style var, style
    output = []
    style.split(';').each do |part|
      key, value = part.split(':')
      output << "#{var}.style['#{key}'] = '#{value}';"
    end
    output.join "\n"
  end
end
