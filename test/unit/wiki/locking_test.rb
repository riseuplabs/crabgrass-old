require File.dirname(__FILE__) + '/../../test_helper'

class Wiki::LockingTest < Test::Unit::TestCase
  fixtures :users, :wikis

  def setup
    @blue = users(:blue)
    @red = users(:red)
  end

  context "A new unsaved wiki" do
    setup do
      @wiki = Wiki.new
    end

    context "after locking" do
      setup do
        assert_nothing_raised {@wiki.lock!(:document, @blue) }
      end

      should_change("the number of saved wikis", :by => 1) { Wiki.count }
      should_change("the number of wiki locks", :by => 1) { WikiLock.count }

      should "get saved" do
        assert !@wiki.new_record?
      end

      should "get a valid wiki lock object created" do
        assert_equal @blue.id, WikiLock.find_by_wiki_id(@wiki.id).locks[:document][:by]
      end
    end
  end

  context "A Wiki with many sections" do

    setup do
      @wiki = wikis(:multi_section)
    end
    should "raise WikiLockError when locking a non-existant section" do
      assert_raises(WikiLockError) {@wiki.lock! 'bad-nonexistant-section-header', @blue}
    end

    should "raise WikiLockError when unlocking a non-existant section" do
      assert_raises(WikiLockError) {@wiki.unlock! 'bad-nonexistant-section-header', @blue}
    end

    context "when user 'blue' locks 'section-two'" do
      setup { @wiki.lock! 'section-two', @blue }


      context "and that user unlocks 'section-two'" do
        setup { @wiki.unlock! 'section-two', @blue }

        should "appear the same to that user and to a different user" do
          assert_same_elements @wiki.sections_open_for(@blue), @wiki.sections_open_for(@red)
          assert_same_elements @wiki.sections_locked_for(@blue), @wiki.sections_locked_for(@red)
        end

        should "appear to a different user that all sections can be edited and none are locked" do
          assert_same_elements @wiki.sections_open_for(@red), @wiki.all_sections
          assert @wiki.sections_locked_for(@red).empty?
        end
      end

      context "for that user" do
        setup {@user = @blue}
        test_open_sections = [:document, 'top-oversection',
          'section-two', 'subsection-for-section-two', 'section-one', 'second-oversection']

          test_open_sections.each { |section_heading|
            should "have the #{section_heading.inspect} section open" do
              assert @wiki.sections_open_for(@user).include?(section_heading)
              assert !@wiki.sections_locked_for(@user).include?(section_heading)
            end

            should "raise no errors when locking #{section_heading.inspect} section" do
              assert_nothing_raised {@wiki.lock! section_heading, @user}
            end

            should "raise no errors when unlocking #{section_heading.inspect} section" do
              assert_nothing_raised {@wiki.unlock! section_heading, @user}
            end
          }

      end

      context "for a different user" do
        setup {@user = @red}

        test_closed_sections = [:document, 'top-oversection', 'section-two', 'subsection-for-section-two']

        test_closed_sections.each { |section_heading|
          should "have the #{section_heading.inspect} section closed" do
            assert !@wiki.sections_open_for(@user).include?(section_heading)
            assert @wiki.sections_locked_for(@user).include?(section_heading)
          end

          should "raise WikiLockError when locking #{section_heading.inspect} section" do
            assert_raises(WikiLockError) {@wiki.lock! section_heading, @user}
          end

          should "raise WikiLockError when unlocking #{section_heading.inspect} section" do
            assert_raises(WikiLockError) {@wiki.unlock! section_heading, @user}
          end
        }

        should "have the neighborhing sections open" do
          assert @wiki.sections_open_for(@user).include?('section-one')
          assert !@wiki.sections_locked_for(@user).include?('section-one')

          assert @wiki.sections_open_for(@user).include?('second-oversection')
          assert !@wiki.sections_locked_for(@user).include?('second-oversection')
        end

        should "raise no errors when locking and unlocking neighboring section" do
          assert_nothing_raised {@wiki.lock! 'section-one', @user }
          assert_nothing_raised {@wiki.lock! 'second-oversection', @user }

          assert_nothing_raised {@wiki.unlock! 'section-one', @user }
          assert_nothing_raised {@wiki.unlock! 'second-oversection', @user }
        end

        should "not raise WikiLockError when trying to break the lock for 'section-two'" do
          assert_nothing_raised {@wiki.unlock! section_heading, @user, :break => true}
        end
      end
    end

    context "when a user 'blue' locks the whole document" do
      setup {@wiki.lock! :document, @blue}

      context "and then 'blue' unlocks the whole document" do
        setup {@wiki.lock! :document, @blue}

        should "appear the same to 'blue' and to a different user" do
          assert_same_elements @wiki.sections_open_for(@blue), @wiki.sections_open_for(@red)
          assert_same_elements @wiki.sections_locked_for(@blue), @wiki.sections_locked_for(@red)
        end

        should "appear to a different user that all sections can be edited and none are locked" do
          assert_same_elements @wiki.sections_open_for(@red), @wiki.all_sections
          assert @wiki.sections_locked_for(@red).empty?
        end
      end

      should "appear to 'blue' that all sections can be edited and none are locked" do
        assert_same_elements @wiki.sections_open_for(@blue), @wiki.all_sections
        assert @wiki.sections_locked_for(@blue).empty?
      end

      should "appear to a different user that no sections can be edited and all are locked" do
        assert @wiki.sections_open_for(@red).empty?
        assert_same_elements @wiki.sections_locked_for(@red), @wiki.all_sections
      end

      should "raise an exception (and keep the same state) when a different user tries to lock the document" do
        assert_raises(WikiLockError) {@wiki.lock! :document, @red}

        assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@blue)
        assert @wiki.sections_open_for(@red).empty?
        assert_same_elements @wiki.all_sections, @wiki.sections_locked_for(@red)
      end

      should "raise an exception (and keep the same state) when a different user tries to lock a section" do
        assert_raises(WikiLockError) {@wiki.lock! 'section-one', @red}

        assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@blue)
        assert @wiki.sections_open_for(@red).empty?
        # require 'ruby-debug';debugger;1-1
        assert_same_elements @wiki.all_sections, @wiki.sections_locked_for(@red)
      end

      context "and that user locks a 'section-one'" do
        setup {@wiki.lock! 'section-one', @blue}

        should "appear to that user that all sections can be edited and none are locked" do
          assert_same_elements @wiki.sections_open_for(@blue), @wiki.all_sections
          assert @wiki.sections_locked_for(@blue).empty?
        end

        should "appear to a different user that no sections can be edited and all are locked" do
          assert @wiki.sections_open_for(@red).empty?
          assert_same_elements @wiki.sections_locked_for(@red), @wiki.all_sections
        end

        context "and then unlocks 'section-one'" do
          setup {@wiki.lock! 'section-one', @blue}

          should "appear to that user that all sections can be edited and none are locked" do
            assert_same_elements @wiki.sections_open_for(@blue), @wiki.all_sections
            assert @wiki.sections_locked_for(@blue).empty?
          end

          should "appear to a different user that no sections can be edited and all are locked" do
            assert @wiki.sections_open_for(@red).empty?
            assert_same_elements @wiki.sections_locked_for(@red), @wiki.all_sections
          end
        end
      end
    end
  end

  # def test_lock_race_condition
  #   w = wikis(:multi_section)
  # 
  #   w.lock(Time.now, users(:orange), 'section-one')
  #   assert_raises(WikiLockError) do
  #     w2 = Wiki.find(w.id)
  #     w2.lock(Time.now, users(:blue), 'section-one')
  #   end
  #   assert_equal ['section-one'], w.reload.locked_sections
  #   assert_equal users(:orange).id, w.locked_by_id('section-one')
  # end

end
