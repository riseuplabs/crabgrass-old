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
      @default ||= find_by_code('en')
    end
  end

  module InstanceMethods
    def percent_complete()
      count = Key.count_all
      if count > 0
        ## something weird is going on. self.id causes stack-level too deep error.
        ## so as a hack, we use self[:id]
        trans_count = Translation.count :conditions => ['language_id = ?', self[:id]]
        (trans_count / count * 100.0).round.to_s + '%'
      else
        "0%"
      end
    end

    def to_param
      self.code
    end
  end

  def self.add_to_class_definition
    lambda do
      has_many :translations, :dependent => :destroy
    end
  end
end

