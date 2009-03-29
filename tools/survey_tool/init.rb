require File.join(File.dirname(__FILE__), 'lib',
                  'survey_user_extension')

apply_mixin_to_model(SurveyUserExtension, "User")
