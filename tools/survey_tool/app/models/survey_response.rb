class SurveyResponse < ActiveRecord::Base
  include ActionView::Helpers::TextHelper # to truncate

  attr_accessible :answers_attributes

  belongs_to :user
  belongs_to :survey
  has_many(:answers, :dependent => :destroy,
           :class_name => 'SurveyAnswer', :foreign_key => 'response_id')
  acts_as_rateable

  # create a new SurveyAnswer for this question
  # or try to load the existing one
  def find_or_build_answer_for_question(question, options = {})
    candidates = answers.select {|a| a.question == question}
    # return if we have an answer object ready
    return candidates.first if candidates.size == 1

    if candidates.empty?
      # we have nothing, create a new one
      answer = question.build_answer
      self.answers.unshift answer
      answer
    else
      # we have more than one answer for this question
      # this is probably a select many question
      if options[:choice_index]
        candidates[options[:choice_index]]
        # answer.position = options[:choice_index]
      else
        candidates.first
      end
    end
  end

  def answers_attributes=(attrs)
    self.answers = []
    attrs.each do |key, params|
      # keys can be either question_id like "37"
      # or question_id_choice_index like "38_choice_2"
      question = SurveyQuestion.find(params['question_id'].to_i)
      self.answers << question.build_answer(params)
    end
  end

  def validate_associated_records_for_answers
    answers.each do |answer|
      label = "'" + truncate(answer.question.label) + "'"
      unless answer.valid?
        answer.errors.each {|attr, msg| self.errors.add(label, msg)}
      end
    end
  end
end
