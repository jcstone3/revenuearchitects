class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :website
      t.integer :user_id
      t.integer :industry_id
      t.timestamps
    end
  end
end
