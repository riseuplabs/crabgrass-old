module Forms
  module Model
    
    # @page will hold the current page of the form
    attr_accessor :page
    
    # for calling on an instance.
    # see def self.pages below
    def define_pages(*page_names)
      for page in page_names
        Forms::Model.module_eval <<-"end_eval"
        def page_#{page.id2name}?
          @page == "#{page.id2name}"
        end
        end_eval
      end
    end 
    
    #
    # modules do not support class method inheritance.
    # this is a hack to get around this. see:
    # http://rcrchive.net/rcr/show/325
    #
    def self.included(klass)
      klass.module_eval do
        # clear all validations for this class
        # so that we can define our own on a per page basis
        write_inheritable_attribute(:validate,nil)
        write_inheritable_attribute(:validate_on_create,nil)
        write_inheritable_attribute(:validate_on_update,nil)
        
        #
        # the method pages() creates methods for testing the current page.
        # used in model validations like so:
        #  pages :first, :second
        #  validates_length_of :subject, :minimum => 4, :if => :page_first
        #  validates_confirmation_of :agreement, :if => :page_second
        #
        def self.pages(*page_names)
          for page in page_names
            module_eval <<-"end_eval"
            def page_#{page.id2name}?
              @page == "#{page.id2name}"
            end
            end_eval
          end
        end 
        
        # 
        # a replacement for the default attr_accessor. 
        # this one calls write_attribute, so that the @attributes array
        # gets updated like you would expect if you did self.my_attribute = "blah"
        # it also makes it so that you can use ActiveRecord#new(hash)
        # ActiveRecord#attributes= for attrs defined with attr_accessor.
        #
        def self.attr_accessor(*attribute_names)
          for attr_name in attribute_names
            attr_name = attr_name.id2name unless attr_name.is_a? String
            module_eval <<-"end_eval"
            def #{attr_name}
              read_attribute "#{attr_name}"
            end
            def #{attr_name}=(value)
              write_attribute "#{attr_name}", value
              @#{attr_name} = value
            end
            end_eval
          end
        end        
      end
    end
    
  end # Model
end # Forms
