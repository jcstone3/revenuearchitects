class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :name
      t.integer :sequence
      t.boolean :is_active
      t.integer :sub_section_id
      t.timestamps
    end
  end
end
