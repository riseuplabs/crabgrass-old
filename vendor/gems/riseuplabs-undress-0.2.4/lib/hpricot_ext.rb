require "hpricot"

module ::Hpricot #:nodoc:
  module Elem::Trav
    def set_style(name, value)
      styles[name.to_s] = value.fast_xs
    end

    def del_style(name)
      styles.delete(name)
    end

    def has_style?(name)
      styles.has_style?(name)
    end

    def get_style(name)
      styles[name]
    end
  end

  class Styles
    def initialize e
      @element = e
    end

    def delete(key)
      p = properties.dup
      if p.delete key
        @element.set_attribute("style", "#{p.map {|pty,val| "#{pty}:#{val}"}.join(";")}")
      end
    end

    def [] key
      properties[key]
    end

    def []= k, v 
      s = properties.map {|pty,val| "#{pty}:#{val}"}.join(";")
      @element.set_attribute("style", "#{s.chomp(";")};#{k}:#{v}".sub(/^\;/, ""))
    end

    def empty?
      return true if properties.size == 0
    end

    def has_style?(key)
      properties.has_key?(key)
    end

    def to_s
      properties.to_s
    end

    def to_h
      properties
    end

    def properties
      return {} if not @element.has_attribute?("style")
      @element.get_attribute("style").split(";").inject({}) do |hash,v|
        v = v.split(":")
        hash.update v.first.strip => v.last.strip
      end
    end
  end

  class Elem #:nodoc:
    def ancestors
      node, ancestors = parent, Elements[]
      while node.respond_to?(:parent) && node.parent
        ancestors << node
        node = node.parent
      end
      ancestors
    end
    
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
