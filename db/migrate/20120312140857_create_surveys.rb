class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer :company_id
      t.integer :size
      t.integer :revenue
      t.date :start_date
      t.date :end_date
      t.boolean :is_active
      t.timestamps
    end
  end
end
