require 'hpricot'

module ::Hpricot
  module Elem::Trav
    def has_style?(name)
    end

    def get_style(name)
    end

    def set_style(name, value)
      styles[name.to_s] = value.fast_xs
    end
  end

  class Styles
    def initialize e
      @element = e
    end

    def []= k, v 
      s = properties.map {|pty,val| "#{pty}:#{val}"}.join(";")
      @element.set_attribute("style", "#{s.chomp(";")};#{k}:#{v}".sub(/^\;/, ""))
    end

    def properties
      return {} if not @element.has_attribute?("style")
      @element.get_attribute("style").split(";").inject({}) do |hash,v|
        v = v.split(":")
        hash.update v.first.strip => v.last.strip
      end
    end

    def to_s
      properties.to_s
    end

    def to_h
      properties
    end
  end

  class Elem
    def change_tag!(new_tag, preserve_attr = true)
      return if not etag
      self.name = new_tag
      attributes.each {|k,v| remove_attribute(k)} if not preserve_attr
    end

    def styles
      Styles.new self
    end
  end
end
