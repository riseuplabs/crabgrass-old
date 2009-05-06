PageClassRegistrar.add(
  'SurveyPage',
  :controller => 'survey_page',
  :icon => 'page_survey',
  :class_display_name => 'survey',
  :class_description => :survey_class_description,
  :class_group => 'surveys',
  :order => 4
)

require File.join(File.dirname(__FILE__), 'lib',
                  'survey_user_extension')

apply_mixin_to_model("User", SurveyUserExtension)

#self.override_views = true
self.load_once = false
