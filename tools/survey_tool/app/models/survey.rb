class Survey < ActiveRecord::Base
  has_many(:questions, :order => :position, :dependent => :destroy,
           :class_name => 'SurveyQuestion')
  has_many(:responses, :dependent => :destroy,
           :class_name => 'SurveyResponse') do
    # returns all responses, except the one of the user herself
    def rateable_by(user)
      self.find(:all, :conditions => ["user_id != ?", user.id])
    end
  
    # returns `count' responses, the given `user' may rate on, but hasn't yet.
    # if an Array of `ids' is given, those responses are fetched first and then
    # filled up until `count' is reached.
    def next_rateables(user, ids=nil, count=3)
      resp = ((ids && ids.any?) ? self.find(ids) : [])
      if (limit=(count-resp.size)) > 0
        all = self.rateable_by(user)
        if (x=all.select { |r| !(ids && ids.include?(r.id)) &&
              !r.ratings.by_user(user).any? }).size < limit
          x += (all-x)[0..limit]
        end
        x.sort! do |a, b|
          (user.rated?(a) && user.rated?(b)) ? 0 : -1
        end
        resp += limit.times.map do
          x.delete(x.rand)
        end
      end
      resp.compact
    end
  end

  
  before_save :update_response_count
  def update_response_count
    self.responses_count = self.responses.size
  end
  
  # def respond!(user, values)
  #   response = SurveyResponse.new(:survey => self, :user => user)
  #   response.save!
  #   self.responses << response
  #   self.save!
  #   values.each_pair do |q, a|
  #     question = SurveyQuestion.find(q)
  #     question.answer!(response, a)
  #   end
  #   response
  # end

  def new_questions_attributes=(question_attributes)
    question_attributes.keys.each do |id|
      if id[0..2] == "new"
        # new question
        attribute = question_attributes[id]
        self.questions << attribute["type"].constantize.create(attribute)
      else
        # old question
        question = self.questions.detect{|q|q.id.to_s == id}
        next unless question
        if question_attributes[id]['deleted']
          question.destroy
        else
          question.update_attributes(question_attributes[id])
        end
      end
    end
  end

end
