#  create_table "survey_questions", :force => true do |t|
#    t.string   "type"
#    t.text     "choices"
#    t.integer  "survey_id",  :limit => 11
#    t.integer  "position",   :limit => 11
#    t.string   "label"
#    t.text     "details"
#    t.boolean  "required"
#    t.datetime "created_at"
#    t.datetime "expires_at"
#    t.string   "regex"
#    t.integer  "maximum",    :limit => 11
#    t.integer  "minimum",    :limit => 11
#    t.boolean  "private",                  :default => false
#  end


class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey
  serialize :choices, Array
  serialize_default :choices, []

  has_many(:answers, :dependent => :destroy, :class_name => 'SurveyAnswer',
           :foreign_key => 'question_id')

  def answer_class
    TextAnswer
  end

  def build_answer(answer_attributes = {})
    answer_attributes[:question_id] = self.id
    answer_class.new(answer_attributes)
  end
  # def answer!(response, value)
  #   answer_class.new(:question => self, :response => response, :value => value).save!
  # end

  def add_question_link_text
    self.class.to_s
  end

  def newline_delimited_choices=(text)
    if text
      self.choices = text.split(/\r?\n/)
    else
      self.choices = []
    end
  end

  def newline_delimited_choices
    self.choices.join("\n")
  end

  # the name of the partial to use for this question
  def partial
    self.class.to_s.underscore
  end

  # for fulltext index
  def to_s
    label
  end

end


######### SHORT TEXT ###################
class ShortTextQuestion < SurveyQuestion
  def add_question_link_text
    I18n.t(:add_short_text_question_link)
  end
end


######### LONG TEXT ###################
class LongTextQuestion < SurveyQuestion
  def add_question_link_text
    I18n.t(:add_long_text_question_link)
  end
end


######### SELECT ONE ###################
class SelectOneQuestion < SurveyQuestion
  def add_question_link_text
    I18n.t(:add_select_one_question_link)
  end
end


######### SELECT MANY ###################
class SelectManyQuestion < SurveyQuestion
  def add_question_link_text
    I18n.t(:add_select_many_question_link)
  end
end

######### IMAGE UPLOAD ###################
class ImageUploadQuestion < SurveyQuestion
  def add_question_link_text
    I18n.t(:upload_image_question_link)
  end

  def answer_class
    AssetAnswer
  end
end

######### VIDEO LINK ###################
class VideoLinkQuestion < SurveyQuestion
  def add_question_link_text
    I18n.t(:video_link_question_link)
  end

  def answer_class
    VideoLinkAnswer
  end
end


######### BOOLEAN ###################
class BooleanQuestion < SurveyQuestion
end
