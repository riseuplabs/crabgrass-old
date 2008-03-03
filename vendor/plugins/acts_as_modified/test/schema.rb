ActiveRecord::Schema.define :version => 0 do
  create_table :people, :force => true do |t|
    t.column :name, :string
    t.column :type, :string
    t.column :country, :string
    t.column :birthdate, :date
    t.column :lucky_number, :integer
    t.column :updated_at, :datetime
    t.column :updated_on, :datetime
    
    t.column :school_id, :integer
  end
  
  create_table :groups, :force => true do |t|
    t.column :name, :string
    t.column :time, :time
  end
  
  create_table :schools, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :animals, :primary_key => 'animal_id', :force => true do |t|
    t.column :name, :string
  end
end
