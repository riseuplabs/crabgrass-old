class Widget < ActiveRecord::Base

  belongs_to :profile

  serialize :options, Hash

  def options
    read_attribute(:options) or {}
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
    self.options.has_key?(key) ? self.options[key] : false
  end

end
