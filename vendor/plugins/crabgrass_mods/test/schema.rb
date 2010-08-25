ActiveRecord::Schema.define(:version => 0) do 
  create_table :crows, :force => true do |t|
    t.string :name
    t.string :last_squawk
    t.datetime :last_squawked_at
  end
  create_table :trees, :force => true do |t|
    t.string :species
    t.integer :location
  end
  create_table :feathers, :force => true do |t|
    t.string :color
    t.integer :crow_id
  end

end
