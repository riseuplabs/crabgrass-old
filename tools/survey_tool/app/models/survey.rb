#  create_table "surveys", :force => true do |t|
#    t.text     "description"
#    t.datetime "created_at"
#    t.integer  "responses_count", :limit => 11, :default => 0
#    t.string   "settings"
#  end
#
class Survey < ActiveRecord::Base

  serialize :settings
  serialize_default :settings, {:edit_may_create => true, :edit_may_see_responses => true}

  has_many(:questions, :order => :position, :dependent => :destroy,
           :class_name => 'SurveyQuestion')

  has_many(:responses, :dependent => :destroy, :class_name => 'SurveyResponse') do
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

  def self.define_boolean_serialized_attrs(*args)
    args.each do |attribute|
      define_method(attribute) {settings[attribute]}
      define_method("#{attribute}?") {settings[attribute]}
      define_method("#{attribute}=") {|v| settings[attribute] = v=="1"}
    end
  end

  define_boolean_serialized_attrs :admin_may_rate,
    :edit_may_create, :edit_may_see_responses,
    :edit_may_rate,   :edit_may_see_ratings,
    :view_may_create, :view_may_see_responses,
    :view_may_rate,   :view_may_see_ratings

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

  protected

  # i can't get the counter cache to work
  def update_counter
    self.update_attribute(:responses_count, self.response_ids.size)
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

