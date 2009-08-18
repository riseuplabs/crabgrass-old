module Wiki::SavingTest
  def self.included(base)
    base.instance_eval do

      context "A new Wiki locked by an user" do
        setup do
          @wiki = Wiki.create :body => 'watermelon'
          @wiki.lock :document, users(:blue)
        end

        should "fail to save with no user set" do
          assert_raises(ActiveRecord::RecordInvalid) { @wiki.save! }
        end

        should "fail to save if version is set too old" do
          w.update_attributes! :body => 'catelope', :version => -1, :user => users(:blue)
        end

        should "fail to save when user is set to non locking user" do
          assert_raises(WikiLockException) do
            w.update_attributes! :body => 'catelope', :user => users(:red)
          end
        end

        should "save when that user is set as wiki owner" do
          assert_nothing_raised do
            w.update_attributes! :body => 'catelope', :user => users(:blue)
          end
        end

        should "save when version is set correctly" do
          assert_nothing_raised do
            w.update_attributes! :body => 'catelope', :user => users(:blue), :version => 0
          end
        end
      end

    end
  end
end