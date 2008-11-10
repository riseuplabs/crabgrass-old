module PostHelper
  # so that really big words don't totally mess with the layout.
  # this is now done by greencloth -e
=begin
  def force_line_breaks body
    words = body.split(' ')
    return words.map do |w|
      ret = []
      if w.size < 45
        w
      else
        while w.size > 45
          step = (w.size < 45 ? w.size : 45)
          ret << w[0..step]
          w = w[step..w.size]
        end
        ret.join("\n")
      end
    end.join(" ")
  end
=end

end
