class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :name, :limit => 50, :null => false 
      t.integer :sequence, :default => 1  
      t.integer :question_count
      t.integer :total_points
      t.integer :questionnaire_id
      t.boolean :is_active

      t.timestamps
    end
  end
end
