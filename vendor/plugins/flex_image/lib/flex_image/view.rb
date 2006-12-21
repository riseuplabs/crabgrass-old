module FlexImage
  class View
    class NotAnImage < RuntimeError #:nodoc:
    end
    
    def initialize(template) #:nodoc:
      @flexi_template = template
    end

    def render(action_view) #:nodoc:
      
      # Eval template in the controller environment
      result = action_view.controller.instance_eval(@flexi_template)
      
      # Raise an error if object returned from template is not an image record
      unless result.is_a?(FlexImage::Model)
        raise NotAnImage, ".flxi template was expected to return a <FlexImage::Model> object, but got a <#{result.class}> instead."
      end
      
      # Return the processed image record
      result  
    end

    class Handler  #:nodoc:
      def initialize(action_view, local_assigns = {})
        @action_view = action_view
      end

      def render(template, local_assigns = {})
        # Set proper content type
        @action_view.controller.headers["Content-Type"] = 'image/jpg'
        
        # Get resulting image from template
        image = FlexImage::View.new(template).render(@action_view)
        
        # Return image data
        image[image.class.data_field]
      ensure
        GC.start
      end
    end
  end
end