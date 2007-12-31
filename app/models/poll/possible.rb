
class Poll::Possible < ActiveRecord::Base

	acts_as_list
  belongs_to :poll
  has_many :votes, :dependent => :destroy
  format_attribute :description  
  validates_presence_of :name
  
  
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
  
  def vote_by_user(user)
    votes.detect {|v| v.user_id == user.id}
  end
  
  def value_by_user(user, default=-1)
    v = vote_by_user(user)
    return v.value if v
    return default
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
    offset = (15 * (score.abs > 17 ? 17 : score.abs))
    if score < 0
       rgb['g'] = rgb['g'] - offset;
       rgb['b'] = rgb['b'] - offset;
    elsif score > 0
       rgb['r'] = rgb['r'] - offset;
       rgb['b'] = rgb['b'] - offset;
    else
      return "efefef"
    end
    "%02x%02x%02x" % [ rgb['r'], rgb['g'], rgb['b'] ]
  end
  
  
end
