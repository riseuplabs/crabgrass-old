class ConvertLanguageCodesToTwoLetters < ActiveRecord::Migration
  def self.up
    Language.find(:all).each do |language|
      language.code.gsub!(/_\w\w/, '')
      language.save!
    end

    User.find(:all, :conditions => "language RLIKE '[a-z][a-z]_[A-Z][A-Z]'").each do |user|
      user.language.gsub!(/_\w\w/, '')
      user.save!
    end

    Group.find(:all, :conditions => "language RLIKE '[a-z][a-z]_[A-Z][A-Z]'").each do |group|
      group.language.gsub!(/_\w\w/, '')
      group.save!
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
