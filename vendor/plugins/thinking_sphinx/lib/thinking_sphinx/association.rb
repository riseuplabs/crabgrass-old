module ThinkingSphinx
  # Associations are created as part of index definitions - used in combination
  # with Active Record's association reflections to determine what attributes
  # are accessible through the relationships.
  class Association
    attr_accessor :reflection
    
    # Instantiate with the parent Field object, the name of the association,
    # and the related reflection.
    def initialize(field, name, reflection)
      @field, @name, @reflection = field, name, reflection
    end
    
    # The model that the association represents
    def model
      @reflection.klass
    end
    
    # Allows comparing of associations based on their reflection
    def eql?(assoc)
      assoc.reflection == @reflection
    end
    
    # Allows comparing of associations based on their reflection
    def hash
      @reflection.hash
    end
  end
end