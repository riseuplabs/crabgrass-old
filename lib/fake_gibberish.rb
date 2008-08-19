# this code adds Gibberish syntax sugar for translations
# right now it doesn't do anything
# in the future it will make "Foo"[:foo] return I18n.t(:foo, :default => "Foo")

module Crabgrass::StringExt
  def brackets_with_translation(*args)
    args = [underscore.tr(' ', '_').to_sym] if args.empty?
    return brackets_without_translation(*args) unless args.first.is_a? Symbol
    self # delete this line and remove the comment bellow in order to add the desired functionality.
    #I18n.translate(args.first, :default => self)
  end

  def self.included(base)
    base.class_eval do
      alias :brackets :[]
      alias_method_chain :brackets, :translation
      alias :[] :brackets
    end
  end
end

String.send :include, Crabgrass::StringExt
