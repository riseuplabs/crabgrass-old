class Survey < ActiveRecord::Base
  
  serialize :settings
  serialize_default :settings, {:responses_enabled => true,
    :rating_enabled => false, :participants_can_rate => true}

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
    
  def rating_enabled() settings[:rating_enabled] end
  def rating_enabled=(v)
    settings[:rating_enabled]=(v=='1' ? true : false) end
  def responses_enabled() settings[:responses_enabled] end
  def responses_enabled=(v)
    settings[:responses_enabled]=(v=='1' ? true : false) end
  def participants_can_rate() settings[:participants_can_rate] end
  def participants_can_rate=(v)
    settings[:participants_can_rate]=(v=='1' ? true : false) end
  alias :rating_enabled? :rating_enabled
  alias :responses_enabled? :responses_enabled
  alias :participants_can_rate? :participants_can_rate
  def responses_disabled() !responses_enabled end
  alias :responses_disabled? :responses_disabled
  def participants_cannot_rate() !participants_can_rate end
  alias :participants_cannot_rate? :participants_cannot_rate
  def responses_disabled=(v)
    settings[:responses_enabled]=(v=='1' ? false : true) end
  def participants_cannot_rate=(v)
    settings[:participants_can_rate]=(v=='1' ? false : true) end
  
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

  # SQL for finding all the responses that a user has not yet rated
  # (excluding their own responses) for a particular survey.
  #
  # vars: [survey_id, user_id, user_id, limit]
  #
  # This query has problems, and will get increasingly slow as the user rates
  # more responses.
  NEEDS_RATING_SQL = "SELECT survey_responses.* FROM survey_responses WHERE survey_responses.survey_id = ? AND survey_responses.user_id != ? AND survey_responses.id NOT IN (SELECT ratings.rateable_id FROM ratings WHERE ratings.rateable_type = 'SurveyResponse' AND ratings.user_id = ?) ORDER BY survey_responses.id LIMIT ?"

end

