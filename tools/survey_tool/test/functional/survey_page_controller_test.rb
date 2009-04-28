require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SurveyPageControllerTest < ActionController::TestCase
    
  fixtures :users, :pages, :groups, :user_participations, :survey_questions,
    :surveys, :survey_responses, :survey_answers
  
  def test_create_survey
    login_as :blue
    post :create, :page => {:title => "a little survey for you"}, :id=>"survey"
    page = assigns(:page)
    
    post :edit, :page_id => page.id, :survey => {:description => 'description'}
    assert assigns(:survey).valid?
    assert assigns(:page).valid?
    assert_not_nil Page.find(assigns(:page).id).data
  end
  
  def test_save_survey
    login_as :blue
    get :edit, :page_id => pages("survey_blank").id
    assert_response :success
    assert_active_tab "Design Survey"

    assert_not_nil assigns(:survey)
    # this will create two new questions
    save_survey_to_blank_page({
      "new_questions_attributes"=>{
        "new_0.4083156603636907"=>{"newline_delimited_choices"=>"sweet\r\nsour\r\npork-flavored\r\nstale", "private"=>"1", "type"=>"SelectOneQuestion", "label"=>"chips", "position"=>"1"},
        "new_0.19274031862237884"=>{"private"=>"0", "type"=>"ShortTextQuestion", "label"=>"how can we help you?", "position"=>"2"}},
      "rating_enabled"=>"1",
      "participants_may_rate"=>"0",
      "responses_enabled"=>"0"
    })

    assert_redirected_to "_page_action" => "edit"

    get :edit, :page_id => pages("survey_blank").id
    assert_active_tab "Design Survey"
    assert_response :success

    survey = assigns(:survey)

    assert_equal "chips", survey.questions[0].label
    assert_equal ["sweet", "sour", "pork-flavored", "stale"], survey.questions[0].choices
    assert_equal "how can we help you?", survey.questions[1].label
    assert_equal true, survey.rating_enabled?
    assert_equal false, survey.participants_may_rate?
    assert_equal false, survey.responses_enabled?
  end

  def test_destroy
    login_as :blue
    
    assert_difference 'Survey.count', -1 do
      post :destroy, :page_id => pages(:survey1).id
    end
  end
  
  protected
  
  def assert_active_tab(tab_text)    
    assert_select ".tabset" do
      assert_select "a.active", {:text => tab_text}
    end
  end

  def assert_tabs(tabs)
    assert_select ".tabset" do
      assert_select ".tab a", {:count => tabs.size} do |tab_links|
        links_text = tab_links.collect {|link| link.children.first.content}
        assert_equal tabs, links_text
      end
    end
  end

  def save_survey_to_blank_page(params)
    post :edit, :page_id => pages("survey_blank").id, :survey => params
  end
end
