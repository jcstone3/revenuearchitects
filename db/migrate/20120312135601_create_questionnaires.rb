class CreateQuestionnaires < ActiveRecord::Migration
  def change
    create_table :questionnaires do |t|
      t.string :name
      t.string :description
      t.integer :industry_id
      t.boolean :is_active
      t.timestamps
    end
  end
end
