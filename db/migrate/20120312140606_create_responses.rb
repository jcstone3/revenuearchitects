class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :survey_id
      t.integer :question_id
      t.string :answer_1
      t.string :answer_2
      t.string :answer_3
      t.timestamps
    end
  end
end
