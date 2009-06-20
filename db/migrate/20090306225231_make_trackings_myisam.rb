class MakeTrackingsMyisam < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE trackings ENGINE=MyISAM")
  end

  def self.down
    execute("ALTER TABLE trackings ENGINE=InnoDB")
  end
end
