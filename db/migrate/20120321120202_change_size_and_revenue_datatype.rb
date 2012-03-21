class ChangeSizeAndRevenueDatatype < ActiveRecord::Migration
  def up
  	change_column :surveys, :size, :string
  	change_column :surveys, :revenue, :string
  end

  def down
  	change_column :surveys, :size, :integer
  	change_column :surveys, :revenue, :integer
  end
end
