class CreateQuestionnaires < ActiveRecord::Migration
  def change
    create_table :questionnaires do |t|
      t.string :name, :limit => 150 
      t.string :description, :limit => 500    
      t.boolean :is_active
      t.timestamps
    end
  end
end
