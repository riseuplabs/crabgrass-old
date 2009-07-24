require File.dirname(__FILE__) + '/../test_helper'

class GroupParticipationTest < Test::Unit::TestCase
  fixtures :groups, :users, :memberships, :group_participations, :pages

  def test_name_change
    group = groups(:rainbow)

    pages = group.pages.select{|page| page.owner_name == group.name}

    group.name = 'colors'
    group.save!

    assert pages.size > 0, 'there should be pages for rainbow'
    pages.each do |page|
      page.reload
      assert_equal group.name, page.owner_name
    end
  end

  def test_associations
    assert check_associations(GroupParticipation)
  end

end
