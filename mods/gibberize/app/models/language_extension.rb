module LanguageExtension
#  def self.included(base)
#    base.extend(ClassMethods)
#    base.instance_eval do
#      include InstanceMethods
#    end
#    base.instance_eval &(self.class_definition())
#  end

  module ClassMethods
    def default
      # TODO: make this configurable
      @default ||= find_by_code('en_US')
    end
  end
 
  module InstanceMethods
    def percent_complete()
      count = Key.count_all
      if count > 0
        (Key.translated(self).count / count * 100.0).round.to_s + '%'
      end
    end

    def to_param
      self.code
    end
  end

  def self.class_definition
    lambda {
      has_many :translations, :dependent => :destroy
    }
  end
end

