ActiveRecord::Schema.define :version => 0 do
  create_table :people, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :group_memberships, :force => true do |t|
    t.column :person_id, :integer
    t.column :group_id, :integer
    t.column :type, :string
  end
  
  create_table :groups, :force => true do |t|
    t.column :name, :string
  end
end
