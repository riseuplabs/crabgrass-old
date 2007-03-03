class Pages::Base < Page
  cattr_accessor :controller, :model, :icon, :type_display

  
  
  #def self.cattr(attr)
  #  module_eval do
  #    define_method(attr) do |value|
  #      @@xx = value || @@xx
  #    end
  #  end
  #end
  
  def self.cattr(attr)
    module_eval <<-"end_eval"
      def #{attr}(value=nil)
        @@#{attr} = value || @@#{attr}
      end
    end_eval
  end  
  
  cattr 'yy'
  
end