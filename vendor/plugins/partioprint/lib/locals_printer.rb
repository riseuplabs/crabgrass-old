# Prints locals as html comments when partial is rendered.
class LocalsPrinter

  def initialize(printer)   
     @printer = printer
   end

  def options
    @printer.options
  end

  def to_s
    print_locals(options[:locals]).to_s + @printer.to_s
  end


  private
  
  def print_locals(locals)
    comment="<!-- START Local variables:-->\n"
    locals.each_pair { |key, value| comment += "<!-- #{key} : #{value.to_json} -->\n" }
    comment+="<!-- END Local variables:-->\n"
    comment
  end

end