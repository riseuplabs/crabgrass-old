class Widget < ActiveRecord::Base

  #
  # Class methods for Widget registry
  #

  def self.widgets
    @@widgets ||= {}
  end

  def self.register(name, options)
    underscore = name.underscore
    prefix = underscore.sub /_widget$/, ''
    sane_defaults = {
      :icon => "/images/widgets/#{prefix}.png",
      :translation => underscore.to_sym,
      :description => "#{underscore}_description".to_sym,
      :settings => [:title],
      :columns => []
    }
    options.reverse_merge! sane_defaults
    widgets[name] = options
  end

  belongs_to :profile

  serialize :options, Hash

  # This is needed so we don't use method missing for it which
  # would in turn get self.name.
  attr_accessor :name

  def options
    read_attribute(:options) or {}
  end

  def type_options
    Widget.widgets[self.name]
  end

  def validate
    if type_options.nil?
      errors.add_to_base "Invalid name #{name} for a Widget."
      return
    end
    invalid_keys = self.options.find do |k,v|
      !type_options[:settings].include?(k)
    end
    if invalid_keys.any?
      errors.add_to_base "Invalid keys #{invalid_keys.join","} for #{name}."
    end
  end

  def partial
    "widgets/#{directory}/show"
  end

  def edit_partial
    "widgets/#{directory}/edit"
  end

  def directory
    dir = self.name.underscore
    dir.sub! /_widget$/, ''
  end

  def title
    self.options[:title]
  end

  def try_option(key)
    options.has_key?(key.to_sym) ? options[key.to_sym] : false
  end

  def method_missing(method, *args)
    if type_options[:settings].include?(method)
      return options[method]
    end
    super
  end

end
