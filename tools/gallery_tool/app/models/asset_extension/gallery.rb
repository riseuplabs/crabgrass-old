module AssetExtension
  module Gallery
    def self.included(base)
      #base.extend(ClassMethods)
      base.instance_eval do
        has_many :showings
        has_many :galleries, :through => :showings
        #include InstanceMethods
      end
    end

    #module ClassMethods
    #end
   
    #module InstanceMethods
    #end
  end
end
