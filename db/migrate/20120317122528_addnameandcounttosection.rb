class Addnameandcounttosection < ActiveRecord::Migration
  def up
  	add_column :sections, :name, :string
    add_column :sections, :question_count, :integer
    add_column :sections,  :total_points, :integer
  end

  def down
  	remove_column :sections, :name
  	remove_column :sections, :question_count
  	remove_column :sections, :total_points
  end
end
