class CreateSkills < ActiveRecord::Migration
  def self.up

    create_table :skills do |t|
      t.string :title
      t.text :description
      t.integer :language_id
      t.integer :page_id
      t.timestamps
      t.integer :user_id
    end
    
    
    #relates 
    create_table :semantics do |t|
      t.integer :skill_id
      t.integer :other_skill_id
      t.integer :user_id
      t.string :comment
      t.float :weight
      t.string :type
    # t.integer :parent_id #this enables grammar structures  
      t.timestamps
     # t.integer :term_id # this enables semantical analysis
                          # use this to define the group of words used as signal for this relation 
    end
    
    
    create_table :taxonomy_items do |t|
      t.integer :skill_id
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :taxonomy_id
    end
    
    create_table :taxonomies do |t|
      t.integer :participant_id
      t.string :participant_type
      t.string :title
      t.timestamps
    end
     
    # enables a user or  group to join a skill
    create_table :involvements do |t|
      t.integer :skill_id
      t.integer :participant_id
      t.string :participant_type
      t.float :weight
      t.string :comment
      t.timestamps
    end
    
    # enables the user to evaluete other user's or group's involvements
    create_table :evaluations do |t|
      t.integer :involvement_id
      t.float :weight
      t.string :comment
      t.integer :user_id
      t.timestamps
    end

    
=begin

# use semantics based on a document term matrix, that can be used e.g. with SVD 

    
    # combines various tags to a term
    create_table :terms do |t|
      t.integer :tag_id
      t.integer :parent_id
    end
    
    
    # relates the roots of the terms with their occurance
    create_table :document_term_matrix do |t|
     t.integer :term_id
     t.integer :document_id
     t.float :occurance
    end
    
=end    
    
    
    
=begin

# alternative to the use of poly_links when linking pages together
  
    create_table :page_similarities do |t|
    end
=end
    
  end

  def self.down
    drop_table :skills
    drop_table :semantics
    drop_table :taxonomies
    drop_table :taxonomy_items
    drop_table :evaluations
    drop_table :involvements
    #drop_table :terms
    #drop_table :document_term_matrix
    #drop_table :page_similarities
  end
end


#test
