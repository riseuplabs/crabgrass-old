class Widget < ActiveRecord::Base

  #
  # Class methods for Widget registry
  #

  def self.initialize_registry(filename)
    seed_filename = [RAILS_ROOT, 'config', filename].join('/')
    widgets = YAML.load_file(seed_filename) || {}
    widgets.each do |name, options|
      self.register(name,options)
    end
  end

  def self.register(name, options)
    underscore = name.underscore
    prefix = underscore.sub /_widget$/, ''
    sane_defaults = {
      :icon => "/images/widgets/#{prefix}.png",
      :translation => underscore.to_sym,
      :description => "#{underscore}_description".to_sym,
      :columns => []
    }
    options.reverse_merge! sane_defaults
    Conf.widgets[name] = options
  end

  SECTIONS = ['main', 'sidebar', 'main_storage', 'sidebar_storage']

  def self.id_for_section(section)
    section = section.sub 'sort_list_', ''
    SECTIONS.index(section) + 1
  end

  def self.for_columns(width)
    Conf.widgets.reject do |name, options|
      !options[:columns].include?(width)
    end
  end

  def self.build_params(hash = {})
    { :name => hash[:name] || hash[:widget].delete(:name),
      :section => hash[:section] || hash[:widget].delete(:section),
      :options => hash[:widget].try.to_options
    }
  end


  belongs_to :profile
  validates_presence_of :profile_id
  validates_presence_of :section
  acts_as_list :scope => 'profile_id = #{profile_id} AND section = #{section}'

  serialize :options, Hash

  has_many :menu_items, :order => 'position' do

    # working around the fact that acts_as_tree does not know scopes
    # we only want to have siblings within the same widget in case
    # parent_id is nil.
    def with_siblings(menu_item)
      self.find_all_by_parent_id menu_item.parent_id
    end

    # this also makes sure all menu items belong to the same
    # widget.
    def update_order(menu_item_ids)
      menu_item_ids.each_with_index do |id, position|
        # find the menu_item with this id
        menu_item = self.find(id)
        menu_item.update_attribute(:position, position)
      end
      self
    end

  end


  # we need this for method missing - so let's make sure
  # it can get called.
  def name
    read_attribute(:name)
  end

  def options
    read_attribute(:options) or {}
  end

  def type_options
    name and Conf.widgets[name]
  end

  validate :name_and_options_match

  def name_and_options_match
    if type_options.nil?
      errors.add_to_base "Invalid name #{name} for a Widget."
      self.name = nil
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

  def small?
    type_options and type_options[:width] == 1
  end

  def width
    if self.section == 2
      18
    elsif self.small?
      10
    else
      25
    end
  end

  def title
    self.options[:title]
  end

  def title_or_name
    self.title.blank? ?
      self.name.sub(/Widget$/, '').underscore.humanize :
      self.title
  end

  def short_title
    t = self.title_or_name
    t.size <= self.width ? t : t[0..self.width-3] + '...'
  end

  def method_missing(method, *args)
    if method_is_option?(method)
      self.options[method]
    else
      super
    end
  end

  def method_is_option?(method)
    type_options and
    type_options[:settings] and
    type_options[:settings].include?(method)
  end
end
