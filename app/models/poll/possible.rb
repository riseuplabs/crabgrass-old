
class Poll::Possible < ActiveRecord::Base

  belongs_to :poll
  has_many :votes  

  # rails doesn't let you serialize instances of auto loaded classes
  # see the bug here: http://dev.rubyonrails.org/ticket/7537
  # i tried config.load paths, i tried requiring all the actions in environment.rb
  # and here (which *sometimes* works), but they didn't work.
  # so, instead, we do this sillyness, taken from 
  # http://wiki.rubyonrails.org/rails/pages/HowtoUseYAMLWithUnknownClasses  
  def action
    #read_attribute('action').scan(/!ruby\/object:(.*) \n/).uniq.each { |c| require c[0].underscore }
    read_attribute('action').scan(/!ruby\/object:(.*) \n/).uniq.each{|classes| mod = Module; classes[0].split('::').each {|const| mod = mod.const_get(const)}}
    YAML.load(read_attribute('action'))
  end
  def action=(s)
    write_attribute('action',YAML.dump(s))
  end
    
end
