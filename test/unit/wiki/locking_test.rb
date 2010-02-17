module Wiki::LockingTest

  def self.included(base)
    base.instance_eval do

      context "A new unsaved wiki" do
        setup do
          @wiki = Wiki.new
        end

        context "after locking" do
          setup do
            assert_nothing_raised {@wiki.lock!(:document, @user) }
          end

          should_change("the number of saved wikis", :by => 1) { Wiki.count }
          should_change("the number of wiki locks", :by => 1) { WikiLock.count }

          should "get saved" do
            assert !@wiki.new_record?
          end

          should "get a valid wiki lock object created" do
            assert_equal @user.id, WikiLock.find_by_wiki_id(@wiki.id).locks[:document][:by]
          end
        end
      end

      context "A Wiki with many sections" do

        setup do
          @wiki = wikis(:multi_section)

          @user = users(:blue)
          @different_user = users(:red)
        end

        should "raise WikiLockError when locking a non-existant section" do
          assert_raises(WikiLockError) {@wiki.lock! 'bad-nonexistant-section-header', @user}
        end

        should "raise WikiLockError when unlocking a non-existant section" do
          assert_raises(WikiLockError) {@wiki.unlock! 'bad-nonexistant-section-header', @user}
        end

        context "when a user locks 'section-two'" do
          setup { @wiki.lock! 'section-two', @user }

          should "not raise WikiLockError when locking 'section-two' section again" do
            assert_nothing_raised {@wiki.lock! 'section-two', @user}
          end

          context "and a different user renames 'section-two' bypassing locks" do
            setup do
              body = @wiki.body.sub('section two', 'section 2')
              @wiki.update_attributes!({:user => @different_user, :body => body, :body_html => nil})
            end

            should "have no section locked for either user" do
              assert @wiki.sections_locked_for(@user).empty?
              assert @wiki.sections_locked_for(@different_user).empty?
            end

            should "have all sections open for either user" do
              assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@user)
              assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@different_user)
            end
          end

          context "and a different user renames 'section-two' without saving" do
            setup do
              @wiki.body = @wiki.body.sub('section two', 'section 2')
            end

            should "have no section locked for either user" do
              assert @wiki.sections_locked_for(@user).empty?
              assert @wiki.sections_locked_for(@different_user).empty?
            end

            should "have all sections open for either user" do
              assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@user)
              assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@different_user)
            end
          end


          context "and a different user locks 'section-one'" do
            setup { @wiki.lock! 'section-one', @different_user }

            should "appear to that user that 'section-two' is open" do
              assert @wiki.sections_open_for(@user).include?('section-two')
            end

            should "appear to the different user that 'section-one' is open" do
              assert @wiki.sections_open_for(@different_user).include?('section-one')
            end
          end

          should "return 'section-two' from section_edited_by" do
            assert_equal 'section-two', @wiki.section_edited_by(@user)
          end

          should "be nil from section_edited_by for a section_edited_by user" do
            assert_nil @wiki.section_edited_by(@different_user)
          end

          context "and that user unlocks 'section-two'" do
            setup { @wiki.unlock! 'section-two', @user }

            should "appear the same to that user and to a different user" do
              assert_same_elements @wiki.sections_open_for(@user), @wiki.sections_open_for(@different_user)
              assert_same_elements @wiki.sections_locked_for(@user), @wiki.sections_locked_for(@different_user)
            end

            should "appear to a different user that all sections can be edited and none are locked" do
              assert_same_elements @wiki.sections_open_for(@different_user), @wiki.all_sections
              assert @wiki.sections_locked_for(@different_user).empty?
            end
          end

          context "for that user" do
            test_open_sections = [:document, 'top-oversection',
                                  'section-two', 'subsection-for-section-two', 'section-one', 'second-oversection']

            test_open_sections.each { |section_heading|
              should "have the #{section_heading.inspect} section open" do
                assert @wiki.sections_open_for(@user).include?(section_heading)
                assert !@wiki.sections_locked_for(@user).include?(section_heading)
              end


              should "raise no errors when unlocking #{section_heading.inspect} section" do
                assert_nothing_raised {@wiki.unlock! section_heading, @user}
              end
            }

          end

          context "for a different user" do
            setup {@user = @different_user}

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

            should "raise no errors when unlocking neighboring section" do
              assert_nothing_raised {@wiki.unlock! 'section-one', @user }
              assert_nothing_raised {@wiki.unlock! 'second-oversection', @user }
            end

            should "not raise WikiLockError when trying to break the lock for 'section-two'" do
              assert_nothing_raised {@wiki.unlock! 'section-two', @user, :break => true}
            end
          end
        end

        context "when a user locks the whole document" do
          setup {@wiki.lock! :document, @user}

          should "appear that this user is a locker_of document" do
            assert_equal @user, @wiki.locker_of(:document)
          end

          should "appear that this user is a locker_of a subsection" do
            assert_equal @user, @wiki.locker_of('section-one')
          end

          should "appear to the same user that document is open for editing" do
            assert @wiki.document_open_for?(@user)
          end

          should "appear to the same user that a document subsection is open for editing" do
            assert @wiki.section_open_for?('section-one', @user)
          end

          should "appear to a different user that document is locked for editing" do
            assert @wiki.document_locked_for?(@different_user)
          end

          should "appear to a different user that a document subsection is locked for editing" do
            assert @wiki.section_locked_for?('section-one', @different_user)
          end

          context "and then that user unlocks the whole document" do
            setup {@wiki.unlock! :document, @user}

            should "appear that no user is a locker_of document" do
              assert_nil @wiki.locker_of(:document)
            end

            should "appear that no user is a locker_of a subsection" do
              assert_nil @wiki.locker_of('section-one')
            end

            should "appear the same to that user and to a different user" do
              assert_same_elements @wiki.sections_open_for(@user), @wiki.sections_open_for(@different_user)
              assert_same_elements @wiki.sections_locked_for(@user), @wiki.sections_locked_for(@different_user)
            end

            should "appear to a different user that all sections can be edited and none are locked" do
              assert_same_elements @wiki.sections_open_for(@different_user), @wiki.all_sections
              assert @wiki.sections_locked_for(@different_user).empty?
            end
          end

          should "appear to that user that all sections can be edited and none are locked" do
            assert_same_elements @wiki.sections_open_for(@user), @wiki.all_sections
            assert @wiki.sections_locked_for(@user).empty?
          end

          should "appear to a different user that no sections can be edited and all are locked" do
            assert @wiki.sections_open_for(@different_user).empty?
            assert_same_elements @wiki.sections_locked_for(@different_user), @wiki.all_sections
          end

          should "raise an exception (and keep the same state) when a different user tries to lock the document" do
            assert_raises(WikiLockError) {@wiki.lock! :document, @different_user}

            assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@user)
            assert @wiki.sections_open_for(@different_user).empty?
            assert_same_elements @wiki.all_sections, @wiki.sections_locked_for(@different_user)
          end

          should "raise an exception (and keep the same state) when a different user tries to lock a section" do
            assert_raises(WikiLockError) {@wiki.lock! 'section-one', @different_user}

            assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@user)
            assert @wiki.sections_open_for(@different_user).empty?
            assert_same_elements @wiki.all_sections, @wiki.sections_locked_for(@different_user)
          end

          should "raise a WikiLockError if that user tries to lock another section" do
            assert_raises(WikiLockError) do
              @wiki.lock! 'section-one', @user
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
  end
end
