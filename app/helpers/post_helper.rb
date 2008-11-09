module PostHelper
  def force_line_breaks body
    words = body.split(' ')
    return words.map do |w|
      ret = []
      if w.size < 65
        body
      else
        while w.size > 65
          step = (w.size < 65 ? w.size : 65)
          ret << w[0..step]
          w = w[step..w.size]
        end
        ret.join("\n")
      end
    end
  end
end
