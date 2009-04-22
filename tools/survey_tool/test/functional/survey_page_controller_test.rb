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

    assert_redirected_to "_page_action" => "your_answers"
    assert_equal "<ul><li>Created a response!</li></ul>", flash[:text]
    assert_equal dolphin_id, assigns("response").user_id
    assert_equal ["a1", "a2", "a3"], assigns("response").answers.map{|a| a.value}

    # check the listing
    get :list, :page_id => pages("survey1").id
    assert_active_tab "List All Answers"
    assert_response :success
    response = assigns("responses").detect {|r| r.user_id == dolphin_id}
    assert_equal ["a1", "a2", "a3"], response.answers.map{|a| a.value}
  end

  def test_edit_response
    blue_id = users(:blue).id
    login_as :blue

    get :your_answers, :page_id => pages("survey1").id
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
    assert_redirected_to "_page_action" => "your_answers"
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

    get :your_answers, :page_id => pages("survey1").id
    assert_response :success
    assert_active_tab "Your Answers"

    assert_select "a[href='/blue/survey-ipsum+214/delete_response/#{assigns("response").id}']"

    post :delete_response, :page_id => pages("survey1").id, :id => assigns("response").id

    assert_redirected_to "_page_action" => "respond"

    get :list, :page_id => pages("survey1").id
    response = assigns("responses").detect {|r| r.user_id == blue_id}
    assert_nil response
    assert_active_tab "List All Answers"
  end

  def test_delete_others_response
    blue_id = users(:blue).id
    login_as :blue

    get :details, :page_id => pages("survey1").id, :id => surveys("1").responses[0].id
    assert_active_tab "List All Answers"
    assert_select "a[href='/blue/survey-ipsum+214/delete_response/#{assigns("response").id}?jump=next']"

    # delete it
    post :delete_response, :page_id => pages("survey1").id, :id => assigns("response").id, :jump => "next"
    assert_redirected_to  "_page_action" => "details", :id => surveys("1").responses[1].id
  end

  def test_rate_answers
    # first, we enable ratings
    login_as :blue
    get :design, :page_id => pages("survey1").id
    assert_response :success
    assert_tabs ["Summary", "Design Questions", "Your Answers", "List All Answers"]

    # enable ratings
    post :save_design, :page_id => pages("survey1").id, :survey => {"rating_enabled" => "1"}
    assert_redirected_to "_page_action" => "design"

    get :design, :page_id => pages("survey1").id
    # new tab should be there
    assert_tabs ["Summary", "Design Questions", "Your Answers", "Rate All Answers", "List All Answers"]

    # do some ratings
    survey = surveys("1")
    get :rate, :page_id => pages("survey1").id
    assert_active_tab "Rate All Answers"
    assert_equal survey.responses[0].id, assigns("response").id
    assert_equal "Select a rating to see the next item.", assigns("survey_notice")
    first_rated_response_id = assigns("response").id

    # rate it
    post :rate, :page_id => pages("survey1").id, :response => first_rated_response_id, :rating => "10"
    assert_response :success

    # rate it as different user
    login_as :red

    # rate again
    post :rate, :page_id => pages("survey1").id, :response => first_rated_response_id, :rating => "2"
    assert_response :success

    # check that the average rating is listed
    get :list, :page_id => pages("survey1").id
    assert_response :success
    rated_response = assigns("responses").detect {|r| r.id == first_rated_response_id}

    assert_not_nil rated_response
    assert_equal 6.0, rated_response.rating
  end

  def test_public
    get :show, :page_id => pages("survey1").id
    assert_response :success
  end

  def test_overwrite_rating
    login_as :blue

    # enable ratings
    post :save_design, :page_id => pages("survey1").id, :survey => {"rating_enabled" => "1"}
    assert_redirected_to "_page_action" => "design"

    # do some ratings
    survey = surveys("1")
    get :rate, :page_id => pages("survey1").id
    first_rated_response_id = assigns("response").id

    # rate the first response
    post :rate, :page_id => pages("survey1").id, :response => first_rated_response_id, :rating => "10"
    assert_response :success

    # check that the rating is recorder
    get :list, :page_id => pages("survey1").id
    assert_response :success
    rated_response = assigns("responses").detect {|r| r.id == first_rated_response_id}

    assert_not_nil rated_response
    assert_equal 10.0, rated_response.rating

    # re-rate everything
    survey.responses.each do |response|
      post :rate, :page_id => pages("survey1").id, :response => response.id, :rating => "7"
      assert_response :success
    end

    # check that the rating is over written
    get :list, :page_id => pages("survey1").id
    assert_response :success
    rated_response = assigns("responses").detect {|r| r.id == first_rated_response_id}

    assert_not_nil rated_response
    assert_equal 7.0, rated_response.rating
  end

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
    post :save_design, :page_id => pages("survey_blank").id, :survey => params
  end
end
