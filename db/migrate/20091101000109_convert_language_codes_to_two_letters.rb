class ConvertLanguageCodesToTwoLetters < ActiveRecord::Migration
  def self.up
    Language.find(:all).each do |language|
      language.code.gsub!(/_\w\w/, '')
      language.save!
    end

    User.find(:all, :conditions => "language RLIKE '[a-z][a-z]_[A-Z][A-Z]'").each do |user|
      user.language.gsub!(/_\w\w/, '')
      begin
        user.save!
      rescue StandardError => err
        if err =~ /Email is an invalid email/
          user.update_attribute('email', '')
          user.save!
        else
          puts "Could not save #{user.login}: "+err
        end
      end
    end

    Group.find(:all, :conditions => "language RLIKE '[a-z][a-z]_[A-Z][A-Z]'").each do |group|
      group.language.gsub!(/_\w\w/, '')
      begin
        group.save!
      rescue StandardError => err
        puts "Could not save #{group.name}: "+err
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
