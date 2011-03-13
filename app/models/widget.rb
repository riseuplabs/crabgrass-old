class Widget < ActiveRecord::Base

  #
  # Class methods for Widget registry
  #

  def self.widgets
    if @widgets.nil?
      self.initialize_registry('widgets.yml')
    end
    @widgets ||= {}
  end

  def self.initialize_registry(filename)
    seed_filename = [RAILS_ROOT, 'config', filename].join('/')
    @widgets = YAML.load_file(seed_filename) || {}
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

  # we need this for method missing - so let's make sure
  # it can get called.
  def name
    read_attribute(:name)
  end

  def options
    read_attribute(:options) or {}
  end

  def type_options
    name and Widget.widgets[name]
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
    name.underscore.sub! /_widget$/, ''
  end

  def title
    self.options[:title]
  end

  def method_missing(method, *args)
    if type_options and type_options[:settings].include?(method)
      self.options[method]
    else
      super
    end
  end

end
