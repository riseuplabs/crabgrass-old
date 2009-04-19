require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SurveyPageControllerTest < ActionController::TestCase
  fixtures :users, :pages, :groups, :user_participations, :survey_questions, :surveys, :survey_responses, :survey_answers
  def test_create_survey
    login_as :blue
    get :design, :page_id => pages("survey_blank").id
    assert_response :success
    assert_active_tab "Design Questions"

    assert_not_nil assigns(:survey)

    # this will create two new questions
    save_survey_to_blank_page({
      "new_questions_attributes"=>{
        "new_0.4083156603636907"=>{"newline_delimited_choices"=>"sweet\r\nsour\r\npork-flavored\r\nstale", "private"=>"1", "type"=>"SelectOneQuestion", "label"=>"chips", "position"=>"1"},
        "new_0.19274031862237884"=>{"private"=>"0", "type"=>"ShortTextQuestion", "label"=>"how can we help you?", "position"=>"2"}},
      "rating_enabled"=>"1",
      "participants_cannot_rate"=>"1",
      "responses_disabled"=>"1"
    })

    assert_redirected_to "_page_action" => "design"

    get :design, :page_id => pages("survey_blank").id
    assert_active_tab "Design Questions"
    assert_response :success

    survey = assigns(:survey)

    assert_equal "chips", survey.questions[0].label
    assert_equal ["sweet", "sour", "pork-flavored", "stale"], survey.questions[0].choices
    assert_equal "how can we help you?", survey.questions[1].label
    assert_equal true, survey.rating_enabled
    assert_equal true, survey.participants_cannot_rate
    assert_equal true, survey.responses_disabled
  end

  def test_new_response
    dolphin_id = users(:dolphin).id
    login_as :dolphin
    post :respond, :page_id => pages("survey1").id, "response"=>
            {
              "answers_attributes"=> {
                "1"=>{"question_id"=>"1", "value"=>"a1"},
                "2"=>{"question_id"=>"2", "value"=>"a2"},
                "3"=>{"question_id"=>"3", "value"=>"a3"}}
            }

    assert_redirected_to "_page_action" => "show"
    assert_active_tab "List All Answers"
    assert_equal "<ul><li>Created a response!</li></ul>", flash[:text]
    assert_equal dolphin_id, assigns("response").user_id
    assert_equal ["a1", "a2", "a3"], assigns("response").answers.map{|a| a.value}

    # check the listing
    get :list, :page_id => pages("survey1").id
    assert_response :success
    response = assigns("responses").detect {|r| r.user_id == dolphin_id}
    assert_equal ["a1", "a2", "a3"], response.answers.map{|a| a.value}
  end

  def test_edit_response
    blue_id = users(:blue).id
    login_as :blue

    get :show, :page_id => pages("survey1").id
    assert_response :success

    assert_select "a[href='/blue/survey-ipsum+214/respond']"

    get :respond, :page_id => pages("survey1").id
    assert_response :success
    assert_active_tab "Your Answers"

    # save new reponse
    post :respond, :page_id => pages("survey1").id, "response"=>
              {
                "answers_attributes"=> {
                  "1"=>{"question_id"=>"1", "value"=>"ba1"},
                  "2"=>{"question_id"=>"2", "value"=>"ba2"},
                  "3"=>{"question_id"=>"3", "value"=>"ba3"}}
              }
    assert_redirected_to "_page_action" => "show"
    assert_equal "<ul><li>Updated your response</li></ul>", flash[:text]
    assert_equal blue_id, assigns("response").user_id
    assert_equal ["ba1", "ba2", "ba3"], assigns("response").answers.map{|a| a.value}

    # check the listing
    get :list, :page_id => pages("survey1").id
    assert_response :success
    assert_active_tab "List All Answers"

    response = assigns("responses").detect {|r| r.user_id == blue_id}
    assert_equal ["ba1", "ba2", "ba3"], response.answers.map{|a| a.value}
  end

  def test_delete_own_response
    blue_id = users(:blue).id
    login_as :blue

    get :show, :page_id => pages("survey1").id
    assert_response :success
    assert_active_tab "Your Answers"


    assert_select "a[href='/blue/survey-ipsum+214/delete_response/#{assigns("response").id}']"

    post :delete_response, :page_id => pages("survey1").id, :id => assigns("response").id

    assert_redirected_to "_page_action" => "show"
    get :show, :page_id => pages("survey1").id
    assert_redirected_to "_page_action" => "respond"

    get :list, :page_id => pages("survey1").id
    response = assigns("responses").detect {|r| r.user_id == blue_id}
    assert_nil response
    assert_tab "List All Answers"
  end

  def test_delete_others_response
    blue_id = users(:blue).id
    login_as :blue

    get :details, :page_id => pages("survey1").id, :id => surveys("1").responses[0].id
    assert_active_tab "List All Answers"
    assert_select "a[href='/blue/survey-ipsum+214/delete_response/#{assigns("response").id}?jump=next']"
    
    # delete it
    post :delete_response, :page_id => pages("survey1").id, :id => assigns("response").id, :jump => "next"
  end

  def assert_active_tab(tab_text)
 
  end
  
  def assert_tabs(tabs)
    tabs.each do |tab_text|
      assert_select ".tabset" do
         assert_select ".tab a", {:text => tab_text}
       end
    end
  end

  def save_survey_to_blank_page(params)
    post :save_design, :page_id => pages("survey_blank").id, :survey => params
  end
end