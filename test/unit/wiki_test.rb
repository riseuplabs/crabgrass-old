require File.dirname(__FILE__) + '/../test_helper'

class WikiTest < Test::Unit::TestCase

  fixtures :users
  fixtures :wikis

  def setup
    @orange_id = users(:orange).id
    @blue_id = users(:blue).id
  end

  def test_creation_group_space
    g = Group.create! :name => 'robots'

    a = WikiPage.create :title => 'x61'
    a.add g; a.save

    b = WikiPage.create :title => 'x61'
    b.add g;

    assert_equal 'x61', a.name, 'name should equal title'
    assert b.name_taken?, 'name should already be taken'
    assert !b.valid?, 'should not be able to have two wikis with the same name'
  end

  def test_lock
    w = Wiki.create :body => 'watermelon'
    w.lock(Time.now, users(:blue))

    assert w.locked?, 'locked should be true'
    assert w.editable_by?(users(:blue)), 'blue should be able to edit wiki'
    assert !w.editable_by?(users(:red)), 'red should not be able to edit wiki'

    assert !w.editable_by?(users(:blue), 'section_one'), 'blue should not be able to edit wiki section one'
    assert !w.editable_by?(users(:red), 'section_one'), 'red should not be able to edit wiki section one'

    w.unlock

    assert w.editable_by?(users(:blue)), 'blue should be able to edit wiki'
    assert w.editable_by?(users(:red)), 'red should be able to edit wiki'
  end


  def test_saving
    w = Wiki.create :body => 'watermelon'
    w.lock(Time.now, users(:blue))

    # version is too old
    assert_raise ErrorMessage do
      w.smart_save! :body => 'catelope', :version => -1, :user => users(:blue)
    end

    # already locked
    assert_raise ErrorMessage do
      w.smart_save! :body => 'catelope', :user => users(:red)
    end

    assert_nothing_raised do
      w.smart_save! :body => 'catelope', :user => users(:blue)
    end

  end

  def test_section_lock
    w = wikis(:multi_section)

    w.lock(Time.now, users(:orange), 'section_one')
    assert w.locked?('section_one'), 'locked section_one should be true'

    assert w.editable_by?(users(:orange), 'section_one'), 'orange should be able to edit wiki section one'
    assert !w.editable_by?(users(:red), 'section_one'), 'red should not be able to edit wiki section one'

    assert w.editable_by?(users(:orange), 'section_two'), 'orange should be able to edit wiki section two'
    assert w.editable_by?(users(:blue), 'section_two'), 'blue should be able to edit wiki section two'

    assert w.editable_by?(users(:orange), :all), 'orange should be able to edit the whole wiki'
    assert !w.editable_by?(users(:red), :all), 'red should not be able to edit the whole wiki'

    w.unlock('section_one')

    assert w.editable_by?(users(:orange), 'section_one'), 'orange should be able to edit wiki section one'
    assert w.editable_by?(users(:red), 'section_one'), 'red should be able to edit wiki section one'
  end

  def test_locked_by_id
    w = wikis(:multi_section)

    assert_nil w.locked_by_id(:all), "no one should be the locker of the whole wiki body"
    assert_nil w.locked_by_id('section_two'), "no one should be the locker of the wiki section two"
    assert_nil w.locked_by_id('section_one'), "no one should be the locker of the wiki section one"

    # lock all sections
    w.lock(Time.now, users(:orange), :all)

    assert_equal @orange_id, w.locked_by_id(:all), "orange should be the locker of the whole wiki body"
    assert_equal @orange_id, w.locked_by_id('section_one'), "orange should appear as the locker of wiki section one"
    assert_equal @orange_id, w.locked_by_id('section_two'), "orange should appear as the locker of wiki section two"
  end

  def test_section_locked_by_id
    w = wikis(:multi_section)

    assert_nil w.locked_by_id(:all), "no one should be the locker of the whole wiki body"
    assert_nil w.locked_by_id('section_two'), "no one should be the locker of the wiki section two"
    assert_nil w.locked_by_id('section_one'), "no one should be the locker of the wiki section one"

    # lock one section
    w.lock(Time.now, users(:orange), 'section_two')

    assert_equal @orange_id, w.locked_by_id(:all), "orange should be the locker of the whole wiki body"
    assert_nil w.locked_by_id('section_one'), "no one should appear as the locker of wiki section one"
    assert_equal @orange_id, w.locked_by_id('section_two'), "orange should appear as the locker of wiki section two"
  end

  def test_list_of_locked_sections
    w = wikis(:multi_section)

    # lock sections by different users
    w.lock(Time.now, users(:orange), 'section_one')
    w.lock(Time.now, users(:blue), 'section_two')

    # check list of all sections and per-users lists
    assert_equal ['section_two', 'section_one'], w.locked_sections, "wiki should have sections one and two locked"
    assert_equal 'section_one', w.currently_editing_section(users(:orange)), "wiki should list section one as locked by orange"
    assert_equal ['section_two'], w.locked_sections_not_by(users(:orange)), "wiki should list section two as locked by users other than orange"
  end

  def test_can_lock_only_one_section
      w = wikis(:multi_section)

      # lock one section
      w.lock(Time.now, users(:orange), 'section_one')
      # should be locked
      assert_equal @orange_id, w.locked_by_id('section_one'), "orange should appear as the locker of wiki section one"

      # locked different section
      w.lock(Time.now, users(:orange), 'section_two')
      # should be unlocked now
      assert_nil w.locked_by_id('section_one'), "orange should not appear as the locker of wiki section one"
      # section two should be locked
      assert_equal @orange_id, w.locked_by_id('section_two'), "orange should appear as the locker of wiki section two"
      assert w.locked_by?(users(:orange), 'section_two'), "orange should appear as the locker of wiki section two"
  end

  def test_wiki_page
  end

  def test_associations
    assert check_associations(Wiki)
  end

end
