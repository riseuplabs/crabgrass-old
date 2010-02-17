require File.dirname(__FILE__) + '/../../test_helper'

module Wiki::VersioningTest
  def self.included(base)
    base.instance_eval do
      context "A new Wiki" do
        setup do
          @wiki = Wiki.new
        end

        context "before saving" do
          should "have no versions" do
            assert @wiki.versions.empty?
          end
        end

        # test chat changing body updates versions only when
        # a new user does it
        context "saved with a body by a user" do
          setup do
            @wiki.update_attributes!(:body => 'hi', :user => @user)
          end

          should_change("versions count", :from => 0, :to => 1) { @wiki.versions.size }

          context "and then saved with the same body by different user" do
            setup do
              @wiki.update_attributes!(:user => @different_user)
            end

            should_not_change("versions count") { @wiki.versions.size }
          end

          context "and saved with a new body by a different user" do
            setup do
              @wiki.update_attributes!(:body => 'hi there', :user => @different_user)
            end

            should_change("versions count", :from => 1, :to => 2) { @wiki.versions.size }

            should_have_latest_body 'hi there'
            should_have_latest_body_html '<p>hi there</p>'
            should_have_latest_raw_structure(WikiTest.raw_structure_for_n_byte_body(8))
          end

          context "and saved with a new body by the same user" do
            setup do
              @wiki.body = 'hey you'
              @wiki.user = users(:blue)
              assert_nothing_raised { @wiki.save! }
            end

            should_not_change("versions count") { @wiki.versions.size }

            should_have_latest_body 'hey you'
            should_have_latest_body_html '<p>hey you</p>'
            should_have_latest_raw_structure(raw_structure_for_n_byte_body(7))
          end
        end

        ### wiki should not create new versions on top of a blank version
        ['', nil].each do |initial_body|
          context "saved with #{initial_body.inspect} body by a user" do
            setup do
              @wiki.update_attributes!(:body => initial_body, :user => @user)
            end

            should_change("versions count", :from => 0, :to => 1) { @wiki.versions.size }

            should_have_latest_body initial_body
            should_have_latest_body_html ''
            should_have_latest_raw_structure(WikiTest.raw_structure_for_n_byte_body(0))

            context "and then saved with new body by a different user" do
              setup do
                @wiki.update_attributes!(:body => 'oi', :user => @user)
              end

              should_not_change("versions count") { @wiki.versions.size }
              should_have_latest_body 'oi'
            end

            context "and then saved with new body by the same user" do
              setup do
                @wiki.update_attributes!(:body => 'oi', :user => @user)
              end

              should_not_change("versions count") { @wiki.versions.size }
              should_have_latest_body 'oi'
            end
          end
        end

        context "saved with 'oi', '' (blank body) and 'vey' bodies by alternating users" do
          setup do
            @wiki.update_attributes!(:body => 'oi', :user => @user)
            @wiki.update_attributes!(:body => '', :user => @different_user)
            @wiki.update_attributes!(:body => 'vey', :user => @user)
          end

          should_change("versions count", :from => 0, :to => 2) { @wiki.versions.size }

          should "have only 'oi' and 'vey' versions" do
            assert_equal ['oi', 'vey'], @wiki.versions.collect(&:body)
          end

          should "have the right user for its versions" do
            assert_equal [@user, @user], @wiki.versions.collect(&:user)
          end
        end



        context "with four versions" do
          setup do
            @wiki = Wiki.create! :body => '1111', :user => @user
            @wiki.update_document!(@different_user, 1, '2222')
            @wiki.update_document!(@user, 2, '3333')
            @wiki.update_document!(@different_user, 3, '4444')
          end
          should_change("versions count", :from => 0, :to => 4) { @wiki.versions.size }

          should "find version 1 body" do
            assert_equal '1111', @wiki.versions.find_by_version(1).body
          end

          should "find version 4 body" do
            assert_equal '4444', @wiki.versions.find_by_version(4).body
          end

          context "after a soft revert to an older version" do
            setup {@wiki.revert_to_version(3, users(:purple)) }

            should "create a new version equal to the older version" do
              assert_equal '3333', @wiki.versions.find_by_version(5).body
            end

            should "revert wiki body" do
              assert_equal '3333', @wiki.body
            end
          end

          context "after a hard revert to an older version" do
            setup {@wiki.revert_to_version!(2, users(:purple))}

            should "revert wiki body" do
              assert_equal '2222', @wiki.body
            end

            should "delete all newer versions" do
              assert_equal 2, @wiki.versions(true).size
            end

            should "keep the version it was reverted to" do
              assert_equal '2222', @wiki.versions.find_by_version(2).body
            end
          end
        end
      end
    end
  end
end
