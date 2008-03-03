ActiveRecord::Schema.define :version => 0 do
  create_table :images, :force => true do |t|
    t.column :data, :binary, :size => 10_000_000, :null => false
  end
  execute "ALTER TABLE `images` MODIFY `data` MEDIUMBLOB"
  
  create_table :file_images, :force => true do |t|
  end
end
