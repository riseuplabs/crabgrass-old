require File.dirname(__FILE__) + '/../test_helper'

class GroupParticipationTest < ActiveSupport::TestCase
  fixtures :groups, :users, :memberships, :group_participations

  def test_name_change
    group = groups(:rainbow)

    pages = group.pages.select{|page| page.owner_name == group.name}

    group.name = 'colors'
    group.save!

    assert pages.size > 0
    pages.each do |page|
      page.reload
      assert_equal group.name, page.owner_name
    end
  end

  def test_associations
    assert check_associations(GroupParticipation)
  end

end
