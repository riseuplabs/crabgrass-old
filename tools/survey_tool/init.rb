define_page_type :SurveyPage, {
  :controller => 'survey_page',
  :icon => 'page_survey',
  :class_group => 'vote',
  :order => 4
}

#require File.join(File.dirname(__FILE__), 'lib',
#                  'survey_user_extension')
#
#apply_mixin_to_model("User", SurveyUserExtension)

