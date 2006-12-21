module FlexImage #:nodoc:
  
  # This module allows for easy rendering of FlexImages form your controller.  You can use the 
  # <tt>Action#flex_image</tt> macro to create an action for you, or you can tailor your own 
  # action if you want more control.
  # 
  # For example, lets say you want a border and a logo.
  # 
  #   class FooController < ApplicationController
  #     def show_my_image
  #       image = MyFlexImage.find(params[:id])
  #       
  #       image.resize!(:size => '500x350')
  #       image.overlay!(
  #         :file => 'public/images/border.png',
  #         :size => :stretch_to_fit
  #       )
  #       image.overlay!(
  #         :file      => 'public/images/logo.png',
  #         :alignment => :bottom_left
  #       )
  #       
  #       render_flex_image(image)
  #     end
  #   end
  #   
  # *WARNING*: Serving different images based on criteria that is not in the URL will not work with
  # page caching since rails is not responsible for serving page cached images.  You may have
  # some luck with action caching, and a +redirect_to+ to other image rendering actions using a
  # :+before_filter+ is probably the best bet.
  # 
  module Controller
    
    # Provides the +flex_image+ method which is used to create image rendering actions on controllers.
    module Action
      
      # Sets up a controller to dispay images.  Simply call the +flex_image+ macro.  It takes the same
      # options as <tt>resize!</tt> in <tt>FlexImage::Model</tt>.  Although there two additional required
      # parameters.
      # 
      # * +action+: the name of the action for rendering image that this macro will create.
      # * +class+: The class object that represents your FlexImage::Model.  This can be a string or the actual
      #   class object.
      #
      #    class ImagesController < ApplicationController
      #      flex_image :action  => :pics,          #required
      #                 :class   => ProductImage,   #required
      #                 :size    => '150x200'
      #                 :overlay => {
      #                   :file      => 'public/images/overlays/logo.png',
      #                   :alignment => :bottom_right,
      #                 }
      #    end
      #
      # Then use the +pics+ action on that controller to see your images like 
      # <tt>/products/pics/9</tt>.
      # 
      def flex_image(defaults)
        defaults = defaults.with_indifferent_access
        unless defaults.include?(:action) && defaults.include?(:class)
          raise ArgumentError, ":action and :class must be defined in image rendering parameters\nProvided: #{defaults.inspect}", caller
        end
        
        self.flex_image_action_defaults ||= {}
        self.flex_image_action_defaults[defaults[:action]] = defaults
        self.flex_image_action_defaults.symbolize_keys!
        
        code = <<-METHOD
          def #{defaults[:action]}
            headers['Cache-Control'] = 'public'
            
            image_options = self.class.flex_image_action_defaults[:#{defaults[:action]}].merge(params.symbolize_keys)
            
            begin
              img = #{defaults[:class]}.find(params[:id])
              img.process!(image_options)
              render_flex_image(img)
            rescue ActiveRecord::RecordNotFound
              render(:text => "<h1>Image (\#{params[:id]}) not Found</h1>", :status => 404)
            end
          end
        METHOD
        
        class_eval code
      end
      
      def color(*args)
        Magick::Pixel.new(*args)
      end
      
    end # Action
    
    def self.included(base) #:nodoc:
      base.extend Action
      base.module_eval { cattr_accessor :flex_image_action_defaults }
    end
    
    protected
      
      # Renders a FlexImage record for display in a browser.  Call in the same way that you would 
      # any other rails render method
      #   
      #   class SomeController < ApplicationController
      #     def show_my_image
      #       image = MyFlexImage.find(params[:id])
      #       image.resize!(:size => '50x40')
      #       render_flex_image(image)
      #     end
      #   end
      #   
      def render_flex_image(img)
        send_data(img[img.class.data_field], :type => 'image/jpeg', :disposition => 'inline')
        GC.start
      end
      
      def color(*args)
        Magick::Pixel.new(*args)
      end
    
  end # Controller
  
  ActionController::Base.class_eval do
    include Controller
  end
  
end # FlexImage

