require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SurveyPageResponseControllerTest < ActionController::TestCase

  fixtures :users, :pages, :groups, :user_participations, :survey_questions,
    :surveys, :survey_responses, :survey_answers

  def test_new_response
    login_as :dolphin

    # the user should exist and have access level :edit

    @user = users(:dolphin)
    assert @user, 'the user should exist'
    @page = pages(:survey_blank)
    assert @page, 'the page should exist'

    assert @user.may?(:edit,@page), 'the user should have the right to edit the page'
    assert !@user.may?(:admin,@page), 'the user should not have the right to admin the page'
    assert users(:blue).may?(:admin, @page)

    get :new, :page_id => @page.id
    assert_response :success

    assert_difference 'SurveyResponse.count' do
      post :make, :page_id => @page.id, "response" => {
        "answers_attributes"=> {
          "1"=>{"question_id"=>"1", "value"=>"a1"},
          "2"=>{"question_id"=>"2", "value"=>"a2"},
          "3"=>{"question_id"=>"3", "value"=>"a3"}}
      }
    end

    #assert_equal 1, assigns(:survey).responses_count
    # ^^ i can't get the counter cache working
    assert_equal "success", flash[:type]
    assert_equal @user.id, assigns("response").user_id
    assert_equal ["a1", "a2", "a3"], assigns("response").answers.map{|a| a.value}

    # check the listing - for only admins can see this, we have to login as blue again
    login_as :blue
    get :list, :page_id => @page.id
    assert_response :success
    assert_equal 1, assigns(:survey).responses(true).size

    assert_active_tab "List Responses"
    response = assigns("responses").detect {|r| r.user_id == @user.id}
    assert_equal ["a1", "a2", "a3"], response.answers.map{|a| a.value}
  end

  def test_edit_response
    blue_id = users(:blue).id
    login_as :blue

    survey = pages("survey1").data
    blue_response = users(:blue).response_for_survey(survey)
    page = pages("survey1")

    get :show, :page_id => page.id, :id => blue_response.id
    assert_response :success
    assert_active_tab "My Response"

    # save new reponse
    post :update, :page_id => pages("survey1").id, :id => blue_response.id,
      "response" => {
        "answers_attributes"=> {
          "1"=>{"question_id"=>"1", "value"=>"ba1"},
          "2"=>{"question_id"=>"2", "value"=>"ba2"},
          "3"=>{"question_id"=>"3", "value"=>"ba3"}
        }
      }

    assert_equal blue_id, assigns("response").user_id
    assert_equal ["ba1", "ba2", "ba3"], assigns("response").answers.map{|a| a.value}

    # check the listing
    get :list, :page_id => pages("survey1").id
    assert_response :success
    assert_active_tab "List Responses"

    response = assigns("responses").detect {|r| r.user_id == blue_id}
    assert_equal ["ba1", "ba2", "ba3"], response.answers.map{|a| a.value}
  end

  def test_delete_own_response
    login_as :red
    user = users(:red)
    page = pages(:survey1)
    response = user.response_for_survey(page.data)

    assert !user.may?(:admin, page)
    assert_difference 'SurveyResponse.count', -1 do
      post :destroy, :page_id => pages("survey1").id, :id => response.id
    end
  end

  def test_delete_others_response
    login_as :blue
    user = users(:blue)
    page = pages("survey1")
    response = survey_responses(:resp1)

    assert user.may?(:admin, page)
    assert response.user_id != user.id
    assert_difference 'SurveyResponse.count', -1 do
      post :destroy, :page_id => page.id, :id => response.id
    end
  end

  def test_rate_answers
    # first, we enable ratings
    login_as :blue
    page = pages(:survey1)
    survey = page.data
    survey.admin_may_rate = "1"
    survey.save

    get :rate, :page_id => page.id
    assert_active_tab "Rate Responses"
    assert_equal survey.responses[0].id, assigns("response").id
    first_rated_response_id = assigns("response").id

    # rate it
    post :rate, :page_id => page.id, :id => first_rated_response_id, :rating => "10"
    assert_response :success

    # rate it as different user
    login_as :orange

    # rate again
    post :rate, :page_id => page.id, :id => first_rated_response_id, :rating => "2"
    assert_response :success

    # check that the average rating is listed
    get :list, :page_id => page.id
    assert_response :success
    rated_response = assigns("responses").detect {|r| r.id == first_rated_response_id}

    assert_not_nil rated_response
    assert_equal 6.0, rated_response.rating
  end


  def test_public
    page = pages("survey1")
    assert page, 'the page should exist'
    get :show, :page_id => page.id
    assert_response :success
  end

  def test_overwrite_rating
    login_as :blue
    page = pages("survey1")
    survey = page.data
    survey.admin_may_rate = "1"
    survey.save

    # do some ratings
    survey = surveys("1")
    get :rate, :page_id => page.id
    first_rated_response_id = assigns("response").id

    # rate the first response
    post :rate, :page_id => page.id, :id => first_rated_response_id, :rating => "10"
    assert_response :success

    # check that the rating is recorder
    get :list, :page_id => page.id
    assert_response :success
    rated_response = assigns("responses").detect {|r| r.id == first_rated_response_id}

    assert_not_nil rated_response
    assert_equal 10.0, rated_response.rating

    # re-rate everything
    survey.responses.each do |response|
      unless response.user_id == users(:blue).id
        post :rate, :page_id => page.id, :id => response.id, :rating => "7"
        assert_response :success
      end
    end

    # check that the rating is over written
    get :list, :page_id => page.id
    assert_response :success
    rated_response = assigns("responses").detect {|r| r.id == first_rated_response_id}

    assert_not_nil rated_response
    assert_equal 7.0, rated_response.rating
  end

  def test_private_questions
    # make a question private
    page = pages(:survey1)
    question = page.data.questions.find_by_label("Another Question")
    question.update_attribute(:private, true)

    login_as :blue
    get :show, :page_id => page.id, :id => 5
    assert_select "h2.question_label", /Another Question/, 'blue should see private question'

    login_as :dolphin
    get :show, :page_id => page.id, :id => 5
    assert_raise(Test::Unit::AssertionFailedError, 'dolphin should not see private Qs') do
      assert_select "h2.question_label", /Another Question/
    end
  end


  protected

  def assert_active_tab(tab_text)
    assert_select ".tabset" do
      assert_select "a.active", {:text => tab_text}
    end
  end

end

