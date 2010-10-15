module Formy

  class Buffer
    def initialize
      @data = ""
    end
    def <<(str)
      @data << str.to_s
    end
    def to_s
      @data
    end
  end

end
