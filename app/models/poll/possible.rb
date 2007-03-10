
class Poll::Possible < ActiveRecord::Base

  belongs_to :poll
  has_many :votes, :dependent => :destroy

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
  
  # the score is the sum of:
  # (vote value) x (count of votes with that value)
  def score
    return @score unless @score.nil?
    scores = {}
    @score = 0
    votes.each do |vote|
      if vote.value
        scores[vote.value] ||= 0
        scores[vote.value] += 1
      end
    end
    scores.each do |weight,count|
      @score += weight * count
    end
    @score
  end

  # returns a color that is very green if the score is high, white if it is close to zero,
  # and very red if the score is low.
  def color
    rgb = {'r'=>255, 'g'=>255, 'b'=>255}
    if score < 0
       rgb['g'] = rgb['g'] - (16*score.abs);
       rgb['b'] = rgb['b'] - (16*score.abs);
    elsif score > 0
       rgb['r'] = rgb['r'] - (16*score);
       rgb['b'] = rgb['b'] - (16*score);
    else
      return "efefef"
    end
    "%02x%02x%02x" % [ rgb['r'], rgb['g'], rgb['b'] ]
  end
  
  
end
