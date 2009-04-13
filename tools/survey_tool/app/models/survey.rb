class Survey < ActiveRecord::Base

  has_many(:questions, :order => :position, :dependent => :destroy,
           :class_name => 'SurveyQuestion')

  has_many(:responses, :dependent => :destroy,
           :class_name => 'SurveyResponse') do
    
    # returns all responses, except the one of the user herself
    #def rateable_by(user)
    #  self.find(:all, :conditions => ["user_id != ?", user.id])
    #end
  
    # returns `count' responses, the given `user' may rate on, but hasn't yet.
    def unrated_by(user, count)
      # (proxy_owner is the Survey)
      self.find_by_sql([NEEDS_RATING_SQL, proxy_owner.id, user.id, user.id, count])
    end

    # returns responses that the user has already rated.
    def rated_by(user, count)
      self.find(:all, :conditions => ['survey_responses.user_id != ? AND ratings.user_id = ?',user.id,user.id], :include => :ratings, :order => 'ratings.created_at ASC', :limit => count)
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

  # SQL for finding all the responses that a user has not yet rated.
  # args: [survey_id, user_id, user_id, limit]
  NEEDS_RATING_SQL = "SELECT survey_responses.* FROM survey_responses WHERE survey_responses.survey_id = ? AND survey_responses.user_id != ? AND survey_responses.id NOT IN (SELECT ratings.rateable_id FROM ratings WHERE ratings.rateable_type = 'SurveyResponse' AND ratings.user_id = ?) ORDER BY survey_responses.id LIMIT ?"

  ALREADY_RATED_SQL = "SELECT survey_responses.* FROM survey_responses WHERE survey_responses.survey_id = ? AND survey_responses.user_id != ? AND survey_responses.id IN (SELECT ratings.rateable_id FROM ratings WHERE ratings.rateable_type = 'SurveyResponse' AND ratings.user_id = ?) ORDER BY survey_responses.id LIMIT ?"


end

