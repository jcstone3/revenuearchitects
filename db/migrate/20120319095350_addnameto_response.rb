class AddnametoResponse < ActiveRecord::Migration
  def up
  	add_column :responses, :name, :string
  end

  def down
  	remove_column :responses, :name
  end
end
