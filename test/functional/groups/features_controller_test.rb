require File.dirname(__FILE__) + '/../../test_helper'
require 'json'

class Groups::FeaturesControllerTest < ActionController::TestCase
  fixtures :groups, :pages, :group_participations, :users

  def setup
    login_as :blue
    @group = groups(:rainbow)
  end

  def test_index
    get :index, :id => @group.name

    assert_response :success
    assert_equal assigns(:features), [], "index action should not list any features when none exist"

    parts = create_some_features 2

    get :index, :id => @group.name

    assert_response :success
    assert_equal assigns(:features), parts, "index action should list features"
  end

  def test_create
    pages = [@group.participations[2].page, @group.participations[4].page]

    xhr :post, :create, :id => @group.name, :page_id => pages.first.id

    assert_response :success
    assert_layout nil
    assert_equal assigns(:features), [pages.first.group_participations.find_by_group_id(@group.id)], "create action should list newly created features"

    ## Append another feature
    xhr :post, :create, :id => @group.name, :page_id => pages.last.id

    assert_response :success
    assert_layout nil
    assert_equal assigns(:features),
                  [pages.first.group_participations.find_by_group_id(@group.id),
                    pages.last.group_participations.find_by_group_id(@group.id)],
                  "create action should append a newly created feature to a list of features"
  end

  def test_destroy
    parts = create_some_features 2

    xhr :delete, :destroy, :id => @group.name, :feature_id => parts.first.id

    assert_response :success
    assert_layout nil
    assert_equal assigns(:features), [parts.last], "destroy action should remove a feature from the features list"

    ## Delete again
    xhr :delete, :destroy, :id => @group.name, :feature_id => parts.last.id

    assert_response :success
    assert_equal assigns(:features), [], "destroy action should clear the features list"
  end

  def test_update
    parts = create_some_features 3

    features_ids = parts.collect(&:id).collect(&:to_i)
    # take from the end and put in front [1, 2, 3] => [3, 1, 2]
    reordered_features_ids = features_ids.dup
    reordered_features_ids.unshift reordered_features_ids.pop

    xhr :put, :update, :id => @group.name, :features_ids => reordered_features_ids

    assert_response :success
    assert_layout nil
    assert_equal assigns(:features).collect(&:id), reordered_features_ids, "update action should reorder the list of features"

    ## Reset the original order
    xhr :put, :update, :id => @group.name, :features_ids => features_ids

    assert_response :success
    assert_equal assigns(:features).collect(&:id), features_ids, "update action should reorder the list of features to the original order"
  end

  def test_autocomplete
    DiscussionPage.create!(:title => 'woozier', :owner => @group)
    DiscussionPage.create!(:title => 'zanier', :owner => @group)

    pages = @group.pages.select {|page| page.title =~ /ier/}
    assert pages.any?

    xhr :get, :auto_complete, :id => @group.name, :query => 'ier'

    assert_response :success
    assert_layout nil

    response = nil
    assert_nothing_raised do
      response = JSON.parse(@response.body)
    end
    assert response.is_a?(Hash), "JSON response should get parsed"

    assert_equal pages.collect(&:title).sort, response["suggestions"].sort, "suggestions should be all the matching page titles"
    assert_equal "ier", response["query"]
    assert_equal pages.collect(&:id).sort, response["data"].sort, "suggestions 'data' field should contain page ids"
  end

  def test_non_xhr_redirect_to_index
    post :create, :id => @group.name
    assert_redirected_to :action => 'index'

    delete :destroy, :id => @group.name
    assert_redirected_to :action => 'index'

    put :update, :id => @group.name
    assert_redirected_to :action => 'index'
  end

  protected
  def create_some_features number
    parts = @group.participations[0, number]
    parts.each {|part| part.feature!}
    parts
  end
end
