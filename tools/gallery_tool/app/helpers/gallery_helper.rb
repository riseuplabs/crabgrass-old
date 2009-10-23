module GalleryHelper
  def detail_view_navigation gallery, previous, this, after # next is reserved
    @detail_view_navigation = link_to("Next"[:next]+"&rsaquo;",
                                      gallery_detail_view_url(gallery, after,
                                                              this.id),
                                      :class => 'next button')+
      link_to("&lsaquo;"+"Previous"[:previous],
              gallery_detail_view_url(gallery, previous, this.id),
              :class => 'previous button')
    ""
  end

  def gallery_detail_view_url gallery, image=nil, this_id=nil
    image = (image.is_a?(Showing) ? image.asset : image)
    page_url(gallery, :action => 'detail_view', :id => (image ? image.id :
                                                        this_id))
  end

  # navigation for gallery. pass elements to show as arguments. possible
  # elements are (right now, maybe more to come):
  #  * count     - shows number of total images (or current image index if we
  #                are in detail_view action)
  #  * download  - link to download the gallery in zipped format. (detail_view:
  #                download this image)
  #  * slideshow - link to GalleryController#slideshow
  #  * edit      - link to edit action (or show if we are in edit action)
  #  * show      - link to show action (no matter where we are)
  #  * upload    - link to display upload box (or go to upload action if JS is
  #                disabled)
  #
  # Elements need to be passed as symbols or strings. They will appear in the
  # order they are given.
  # Raises an argument error if the element doesn't exist.
  def gallery_navigation *elements
    available_elements = {
      :count => lambda {
        '<p class="meta">'+if @image_index
                             'Photo {number} of {count}'[:image_count, {:number => @image_index.to_s, :count => @image_count.to_s }]
                           else
                             "{count} Images"[:image_count_total, { :count => @image_count.to_s }]
                           end+'</p>'
      },
      :download => lambda {
        if @showing || @image
          image = (@showing ? @showing.image : @image)
          link_to("Download"[:download],
                  page_url(@page,
                           :action => 'download',
                           :image_id => image.id),
                  :class => "small_icon folder_picture_16")
        else
          link_to("Download Gallery"[:download_gallery],
                  page_url(@page, :action => 'download'),
                  :class => "small_icon folder_picture_16")
        end
      },
      :slideshow => lambda {
        link_to("View Slideshow"[:view_slideshow],
                page_url(@page, :action => 'slideshow'),
                :target => '_blank', :class => "small_icon application_view_gallery_16")
      },
      :edit => lambda {
        unless params[:action] == 'edit'
          link_to("Edit Gallery"[:edit_gallery],
                  page_url(@page, :action => 'edit'),
                  :class => "small_icon picture_edit_16")
        else
          available_elements[:show].call
        end
      },
      :detail_view => lambda {
        @detail_view_navigation or ""
      },
      :upload => lambda {
        javascript_tag("upload_target = document.createElement('div');
                        upload_target.id = 'target_for_upload';
                        upload_target.hide();
                        $$('body').first().appendChild(upload_target);")+
        spinner('show_upload')+
        link_to_remote("Upload"[:upload_images],
                       { :url => page_url(@page, :action => 'upload'),
                         :update => 'target_for_upload',
                         :loading =>'$(\'show_upload_spinner\').show();',
                         :success => 'upload_target.show();',
                         :complete => '$(\'show_upload_spinner\').hide();'},
                       :class => "small_icon page_gallery_16")
      },
      :add_existing => lambda {
        link_to("add existing image"[:add_existing_image],
                page_url(@page, :action => 'find'),
                :class => "small_icon plus_16")
      },
    }

    output  = '<div class="gallery-nav">'
    output << available_elements[:detail_view].call
    output << available_elements[:count].call
    output << '<span class="gallery-actions">'
    output << available_elements[:edit].call unless params[:action] == 'edit'
    output << available_elements[:download].call
    output << available_elements[:slideshow].call
    output << available_elements[:add_existing].call unless params[:action] == 'find'
    output << available_elements[:upload].call
    output << '</span>'
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
                   :success => "update_notifier('#{'Successfully undeleted image.'[:successful_undelete_image]};');undo_remove(#{image_id}, #{position});")
  end

  def gallery_delete_image(image, position)
    link_to_remote('', {
                     :url => {
                       :controller => 'gallery',
                       :action => 'remove',
                       :page_id => @page.id,
                       :id => image.id,
                       :position => position
                     },
                     :update => 'gallery_notify_area',
                     :loading => "update_notifier('#{'Removing image...'[:removing_image]}', true);"
                   }, :title => 'Remove from gallery'[:remove_from_gallery],
                   :class => 'small_icon minus_16')
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

  def gallery_make_cover(image)
    extra_output = ""
    html_options = {
      :id => "make_cover_link_#{image.id}"
    }
    if image.is_cover_of?(@page)
      html_options[:style] = "display:none;"
      extra_output += javascript_tag("var current_cover = #{image.id};")
    end
    options = {
      :url => page_url(@page, :action => 'make_cover', :id => image.id),
      :update => 'gallery_notify_area',
      :loading => "$('gallery_notify_area').innerHTML = '#{"Changing cover..."[:changing_cover]}';
                   $('gallery_spinner').show();",
      :complete => "$('gallery_spinner').hide();",
      :success => "$('make_cover_link_'+current_cover).show();
                   $('make_cover_link_#{image.id}').hide();"
    }
    link_to_remote(image_tag("png/16/mime_image.png", :title =>
                             'make this image the albums cover'[:make_album_cover]),
                   options, html_options)+extra_output
  end

  def image_title image
    change_title = "$('change_title_form').show();$('detail_image_title').hide();return false;"
    output = content_tag :p, image.page.title, :class => 'description',
       :id => 'detail_image_title', :onclick => change_title
    output << render(:partial => 'change_image_title', :locals => { :image => image })
    return output
  end

  def star_for_image image
    star = (@upart and @upart.star?)
    add_options = {
      :id => "add_star_link"
    }
    remove_options = {
      :id => "remove_star_link"
    }
    star_img = image_tag('icons/small_png/star_outline.png')
    nostar_img = image_tag('icons/small_png/star.png')
    (star ? add_options : remove_options).merge!(:style => "display:none;")
    content_tag(:span, link_to_remote(star_img+:add_star.t,
                                      :url => page_url(@page,
                                        :action => 'add_star',
                                        :id => image.id),
                                      :update => 'tfjs'), add_options)+
      content_tag(:span, link_to_remote(nostar_img+:remove_star.t,
                                        :url => page_url(@page,
                                          :action => 'remove_star',
                                          :id => image.id),
                                        :update => 'tfjs'), remove_options)
  end
end
