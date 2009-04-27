require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SurveyPageResponseControllerTest < ActionController::TestCase
    
  fixtures :users, :pages, :groups, :user_participations, :survey_questions,
    :surveys, :survey_responses, :survey_answers
    
  def test_new_response
    dolphin_id = users(:dolphin).id
    login_as :dolphin
    
    # the user should exist and have access level :edit
    
    @user = users(:dolphin)
    assert @user, 'the user should exist'
    @page = pages("survey1")
    assert @page, 'the page should exist'
    
    assert @user.may?(:edit,@page), 'the user should have the right to edit the page'
    assert !@user.may?(:admin,@page), 'the user should not have the right to admin the page'
    
    get :new, :page_id => @page.id
    assert_response :success
      
    post :make, :page_id => @page.id, "response" => {
      "answers_attributes"=> {
        "1"=>{"question_id"=>"1", "value"=>"a1"},
        "2"=>{"question_id"=>"2", "value"=>"a2"},
        "3"=>{"question_id"=>"3", "value"=>"a3"}}
    }

#    assert_redirected_to "_page_action" => "show"
    assert_equal "info", flash[:type]
    assert_equal dolphin_id, assigns("response").user_id
    assert_equal ["a1", "a2", "a3"], assigns("response").answers.map{|a| a.value}

    # check the listing - for only admins can see this, we have to login as blue again
    login_as :blue
    get :list, :page_id => @page.id
    assert_active_tab "List All Responses"
    assert_response :success
    response = assigns("responses").detect {|r| r.user_id == dolphin_id}
    assert_equal ["a1", "a2", "a3"], response.answers.map{|a| a.value}
  end

=begin
  def test_edit_response
    blue_id = users(:blue).id
    login_as :blue

    survey = pages("survey1").data
    blue_response = users(:blue).response_for_survey(survey)
    page = pages("survey1")
    
    get :show, :page_id => page.id, :id => blue_response.id
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
    
    @page = pages("survey1")
    assert @page, 'the page should exist'    
    
    get :design, :page_id => @page.id
    assert_response :success
    assert_tabs ["Summary", "Design Questions", "Your Answers", "List All Answers"]

    # enable ratings
    post :save_design, :page_id => @page.id, :survey => {"rating_enabled" => "1"}
    assert_redirected_to "_page_action" => "design"

    get :design, :page_id => @page.id
    # new tab should be there
    assert_tabs ["Summary", "Design Questions", "Your Answers", "Rate All Answers", "List All Answers"]

    # do some ratings
    survey = surveys("1")
    get :rate, :page_id => @page.id
    assert_active_tab "Rate All Answers"
    assert_equal survey.responses[0].id, assigns("response").id
    assert_equal "Select a rating to see the next item.", assigns("survey_notice")
    first_rated_response_id = assigns("response").id

    # rate it
    post :rate, :page_id => @page.id, :response => first_rated_response_id, :rating => "10"
    assert_response :success

    # rate it as different user    
    login_as :red
    
    # rate again
    post :rate, :page_id => @page.id, :response => first_rated_response_id, :rating => "2"
    assert_response :success

    # check that the average rating is listed
    get :list, :page_id => @page.id
    assert_response :success
    rated_response = assigns("responses").detect {|r| r.id == first_rated_response_id}

    assert_not_nil rated_response
    assert_equal 6.0, rated_response.rating
  end

  def test_public
    @page = pages("survey1")
    assert @page, 'the page should exist'
    get :show, :page_id => @page.id
    assert_response :success
  end

  def test_overwrite_rating
    login_as :blue
    
    @page = pages("survey1")
    assert @page, 'the page should exist'
    
    # enable ratings
    post :save_design, :page_id => @page.id, :survey => {"rating_enabled" => "1"}
    assert_redirected_to "_page_action" => "design"

    # do some ratings
    survey = surveys("1")
    get :rate, :page_id => @page.id
    first_rated_response_id = assigns("response").id

    # rate the first response
    post :rate, :page_id => @page.id, :response => first_rated_response_id, :rating => "10"
    assert_response :success

    # check that the rating is recorder
    get :list, :page_id => @page.id
    assert_response :success
    rated_response = assigns("responses").detect {|r| r.id == first_rated_response_id}

    assert_not_nil rated_response
    assert_equal 10.0, rated_response.rating

    # re-rate everything
    survey.responses.each do |response|
      post :rate, :page_id => @page.id, :response => response.id, :rating => "7"
      assert_response :success
    end

    # check that the rating is over written
    get :list, :page_id => @page.id
    assert_response :success
    rated_response = assigns("responses").detect {|r| r.id == first_rated_response_id}

    assert_not_nil rated_response
    assert_equal 7.0, rated_response.rating
  end
=end

  protected
  
  def assert_active_tab(tab_text)    
    assert_select ".tabset" do
      assert_select "a.active", {:text => tab_text}
    end
  end
  
end

