class AddDescToQuestion < ActiveRecord::Migration
  def change
  	add_column :questions, :description, :string, :limit =>1000
  end
end
