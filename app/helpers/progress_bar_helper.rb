module ProgressBarHelper

  def render_form_with_progress_for(object, options)
    locals = { :object => object,
      :upload_id => options.delete(:upload_id),
      :options => options }
    render :partial => '/common/progress_bar/form', :locals => locals
  end

  def form_with_progress_for(object, options)
    options[:html] ||= {}
    options[:html].merge! :multipart => true,
      :target => 'upload_frame'
    form_for(object, options) do |f|
      yield f
    end
  end

  def upload_iframe_options(object)
    id = case object
         when Symbol, String
           object.to_s
         when ActiveRecord::Base
           object.class.class_name
         end
    id += '_upload_form'
    { :id    => id,
      :name  => id,
      :style => "width:1px;height:1px;border:0px",
      :src   => "about:blank"
    }
  end

end
