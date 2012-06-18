class AddDeleteToSection < ActiveRecord::Migration
  def up
  	
  	add_column :sub_sections, :deleted_at, :datetime

  end
end
