class Widget < ActiveRecord::Base

  belongs_to :profile

  serialize :options, Hash

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

end
