module RoutingFilter
  class CrabgrassRoutingFilter < Base
    def around_recognize(route, path, env)
      # Alter the path here before it gets recognized. 
      # Make sure to yield (calls the next around filter if present and 
      # eventually `recognize_path` on the routeset):
      returning yield do |params|
        # You can additionally modify the params here before they get passed
        # to the controller.
      end
    end

    def around_generate(controller, *args, &block)
      # Alter arguments here before they are passed to `url_for`. 
      # Make sure to yield (calls the next around filter if present and 
      # eventually `url_for` on the controller):

      puts around_generate
      puts [controller, args].inspect

      returning yield do |result|
        # You can change the generated url_or_path here. Make sure to use
        # one of the "in-place" modifying String methods though (like sub! 
        # and friends).
      end
    end
  end
end

