class Possible < ActiveRecord::Base

  acts_as_list
  belongs_to :poll
  has_many :votes, :dependent => :destroy do
    # disable votes collection builder, since we want the vote to take it's type from the poll
    %w(build create create!).each do |method_name|
      define_method(method_name) {
        raise "Don't call 'possible.votes.#{method_name}' -- user 'votable.votes.#{method_name}' instead"
      }
    end
  end

  format_attribute :description
  validates_presence_of :name

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


  protected

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

end
