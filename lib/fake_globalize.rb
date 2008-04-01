

class String 
  def t
    self # this is a stub for translation
  end
  
  def /(*args)
    self.%(*args)
  end
end 

def _(str)
  str #stub for translations
end

class Date
  def loc(fmt)
    self.strftime(fmt)
  end
end

class Time
  def loc(fmt)
    self.strftime(fmt)
  end
end

