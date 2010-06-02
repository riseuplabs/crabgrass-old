require File.dirname(__FILE__) + '/../../test_helper'

class RequestToRemoveUserTest < ActiveSupport::TestCase
  fixtures :users, :groups, :requests, :memberships, :federatings

  def setup
    # 6 in total users in rainbow:
    # ["blue", "orange", "purple", "yellow", "red", "green"]
    @request = RequestToRemoveUser.create! :created_by => users(:red), :recipient => groups(:rainbow), :requestable => users(:orange)
    @group = groups(:rainbow)
  end

  def test_voting_on_request
    @request.approve_by!(users(:green))

    # shouldn't affect the state
    assert_equal 'pending', @request.state
  end

  def test_instant_approval
    @request.approve_by!(users(:green))

    pretend_we_are_in_the_future!
    @request.tally!

    assert_equal 'approved', @request.state
    assert !@group.reload.users.include?(users(:orange))
  end

  # 1 approval, 3 rejections
  def test_instant_rejection
    @request.approve_by!(users(:green))

    @request.reject_by!(users(:blue))
    @request.reject_by!(users(:orange))
    @request.reject_by!(users(:purple))

    assert_equal 'rejected', @request.state
    assert @group.reload.users.include?(users(:orange))
  end

  def test_delayed_approval
    # 2/3 or more of total votes cast must approve
    @request.approve_by!(users(:green))
    @request.approve_by!(users(:blue))
    @request.reject_by!(users(:purple))

    pretend_we_are_in_the_future!
    @request.tally!

    assert_equal 'approved', @request.state
    assert !@group.reload.users.include?(users(:orange))
  end

  def test_delayed_rejection
    # 2/3 or more of total votes cast must approve
    # there is only 1/2 in this case
    @request.approve_by!(users(:green))
    @request.reject_by!(users(:purple))

    pretend_we_are_in_the_future!
    @request.tally!

    assert_equal 'rejected', @request.state
    assert @group.users.include?(users(:orange))
  end

  def test_voting_scenarios
    voting_scenarios.each do |scenario|
      request = RequestToRemoveUser.create! :created_by => users(:red), :recipient => groups(:rainbow), :requestable => users(:blue)
      # blue should never vote, because vote by user proposed for deletion is treated differently
      users = @group.users.clone.select {|u| u.id != users(:blue).id}

      # do the votes
      scenario[:approve].times do
        user = users.shift
        request.approve_by!(user)
      end

      scenario[:reject].times do
        user = users.shift
        request.reject_by!(user)
      end

      # check that the specified outcome happened
      if scenario[:instant]
        assert_equal scenario[:instant], request.state, "On scenario: #{scenario}"
      else
        assert_equal 'pending', request.state, "On scenario: #{scenario}"

        pretend_we_are_in_the_future!
        request.tally!
        assert_equal scenario[:delayed], request.state, "On scenario: #{scenario}"
      end

      request.destroy
      @group.add_user!(users(:blue)) if !@group.reload.users.include?(users(:blue))
    end

  end

  def pretend_we_are_in_the_future!
    future_time = Time.now + 2.months
    Time.stubs(:now).returns(future_time)
  end

  def reset_time_to_present!
    teardown_stubs
  end


  protected

  def voting_scenarios
    [
      # 0 rejections
      {:approve => 0, :reject => 0, :delayed => 'approved'},
      {:approve => 1, :reject => 0, :delayed => 'approved'},
      {:approve => 2, :reject => 0, :delayed => 'approved'},
      {:approve => 3, :reject => 0, :delayed => 'approved'},

      {:approve => 4, :reject => 0, :instant => 'approved'},
      {:approve => 5, :reject => 0, :instant => 'approved'},

      # 1 rejections
      {:approve => 0, :reject => 1, :delayed => 'rejected'},
      {:approve => 1, :reject => 1, :delayed => 'rejected'},
      {:approve => 2, :reject => 1, :delayed => 'approved'},
      {:approve => 3, :reject => 1, :delayed => 'approved'},

      {:approve => 4, :reject => 1, :instant => 'approved'},

      # 2 rejections
      {:approve => 0, :reject => 2, :delayed => 'rejected'},
      {:approve => 1, :reject => 2, :delayed => 'rejected'},
      {:approve => 2, :reject => 2, :delayed => 'rejected'},
      {:approve => 3, :reject => 2, :delayed => 'rejected'},


      # 3 rejections
      {:approve => 0, :reject => 3, :instant => 'rejected'},
      {:approve => 1, :reject => 3, :instant => 'rejected'},
      {:approve => 2, :reject => 3, :instant => 'rejected'},

      # 4 rejections
      {:approve => 0, :reject => 4, :instant => 'rejected'},
      {:approve => 1, :reject => 4, :instant => 'rejected'},

      # 5 rejections
      {:approve => 0, :reject => 5, :instant => 'rejected'}
    ]
  end

end
