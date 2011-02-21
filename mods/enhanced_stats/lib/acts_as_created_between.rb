module ActsAsCreatedBetween

  def self.included(base)
    base.extend CreatedBetween
  end

  module CreatedBetween
    def acts_as_created_between()
      self.class_eval do
        named_scope(:created_between, lambda do |from, to|
          to += ' 23:59:59'
          {:conditions => {:created_at => from..to} }
        end)
      end
    end
  end

end
