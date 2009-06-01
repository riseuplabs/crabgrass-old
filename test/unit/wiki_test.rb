require File.dirname(__FILE__) + '/../test_helper'

class WikiTest < Test::Unit::TestCase

  fixtures :users, :wikis

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

  def test_creation_user_space
    a = WikiPage.create :title => 'x61', :owner => 'blue', :user => users(:blue)
    b = WikiPage.create :title => 'x61', :owner => 'blue', :user => users(:blue)

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

    assert !w.editable_by?(users(:blue), 'section-one'), 'blue should not be able to edit wiki section one'
    assert !w.editable_by?(users(:red), 'section-one'), 'red should not be able to edit wiki section one'

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

    w.lock(Time.now, users(:orange), 'section-one')
    assert w.locked?('section-one'), 'locked section-one should be true'

    assert w.editable_by?(users(:orange), 'section-one'), 'orange should be able to edit wiki section one'
    assert !w.editable_by?(users(:red), 'section-one'), 'red should not be able to edit wiki section one'

    assert w.editable_by?(users(:orange), 'section-two'), 'orange should be able to edit wiki section two'
    assert w.editable_by?(users(:blue), 'section-two'), 'blue should be able to edit wiki section two'

    assert w.editable_by?(users(:orange), :all), 'orange should be able to edit the whole wiki'
    assert !w.editable_by?(users(:red), :all), 'red should not be able to edit the whole wiki'

    w.unlock('section-one')

    assert w.editable_by?(users(:orange), 'section-one'), 'orange should be able to edit wiki section one'
    assert w.editable_by?(users(:red), 'section-one'), 'red should be able to edit wiki section one'
  end

  def test_locked_by_id
    w = wikis(:multi_section)

    assert_nil w.locked_by_id(:all), "no one should be the locker of the whole wiki body"
    assert_nil w.locked_by_id('section-two'), "no one should be the locker of the wiki section two"
    assert_nil w.locked_by_id('section-one'), "no one should be the locker of the wiki section one"

    # lock all sections
    w.lock(Time.now, users(:orange), :all)

    assert_equal @orange_id, w.locked_by_id(:all), "orange should be the locker of the whole wiki body"
    assert_equal @orange_id, w.locked_by_id('section-one'), "orange should appear as the locker of wiki section one"
    assert_equal @orange_id, w.locked_by_id('section-two'), "orange should appear as the locker of wiki section two"
  end

  def test_section_locked_by_id
    w = wikis(:multi_section)

    assert_nil w.locked_by_id(:all), "no one should be the locker of the whole wiki body"
    assert_nil w.locked_by_id('section-two'), "no one should be the locker of the wiki section two"
    assert_nil w.locked_by_id('section-one'), "no one should be the locker of the wiki section one"

    # lock one section
    w.lock(Time.now, users(:orange), 'section-two')

    assert_equal @orange_id, w.locked_by_id(:all), "orange should be the locker of the whole wiki body"
    assert_nil w.locked_by_id('section-one'), "no one should appear as the locker of wiki section one"
    assert_equal @orange_id, w.locked_by_id('section-two'), "orange should appear as the locker of wiki section two"
  end

  def test_list_of_locked_sections
    w = wikis(:multi_section)

    # lock sections by different users
    w.lock(Time.now, users(:orange), 'section-one')
    w.lock(Time.now, users(:blue), 'section-two')

    # check list of all sections and per-users lists
    assert_equal ['section-two', 'section-one'].sort, w.locked_sections.sort, "wiki should have sections one and two locked"
    assert_equal 'section-one', w.currently_editing_section(users(:orange)), "wiki should list section one as locked by orange"
    assert_equal ['section-two'], w.locked_sections_not_by(users(:orange)), "wiki should list section two as locked by users other than orange"
  end

  def test_lock_race_condition
    w = wikis(:multi_section)

    w.lock(Time.now, users(:orange), 'section-one')
    assert_raises WikiLockException do 
      w2 = Wiki.find(w.id)
      w2.lock(Time.now, users(:blue), 'section-one')
    end
    assert_equal ['section-one'], w.reload.locked_sections
    assert_equal users(:orange).id, w.locked_by_id('section-one')
  end

  def test_can_lock_only_one_section
      w = wikis(:multi_section)

      # lock one section
      w.lock(Time.now, users(:orange), 'section-one')
      # should be locked
      assert_equal @orange_id, w.locked_by_id('section-one'), "orange should appear as the locker of wiki section one"

      # locked different section
      w.lock(Time.now, users(:orange), 'section-two')
      # should be unlocked now
      assert_nil w.locked_by_id('section-one'), "orange should not appear as the locker of wiki section one"
      # section two should be locked
      assert_equal @orange_id, w.locked_by_id('section-two'), "orange should appear as the locker of wiki section two"
      assert w.locked_by?(users(:orange), 'section-two'), "orange should appear as the locker of wiki section two"
  end

  def test_wiki_page
  end

  def test_reverting
    wiki = Wiki.create! :body => '1111'    
    wiki.smart_save!(:body => '2222', :user => users(:red))
    wiki.smart_save!(:body => '3333', :user => users(:green))
    wiki.smart_save!(:body => '4444', :user => users(:blue))
    assert_equal 4, wiki.versions.size
    assert_equal '1111', wiki.versions.find_by_version(1).body
    assert_equal '4444', wiki.versions.find_by_version(4).body

    # soft revert
    wiki.revert_to_version(3, users(:purple))
    assert_equal '3333', wiki.versions.find_by_version(5).body

    # hard revert
    wiki.revert_to_version!(4, users(:purple))
    assert_equal '4444', wiki.versions.find_by_version(4).body
    assert_equal 4, wiki.versions(true).size
  end

  def test_associations
    assert check_associations(Wiki)
  end

end
