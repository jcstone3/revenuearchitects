class AddnametoResponse < ActiveRecord::Migration
  def up
  	add_column :response, :name, :string
  end

  def down
  	remove_column :response, :name
  end
end
