class AddColumnInSections < ActiveRecord::Migration
  def up
  	add_column :sections, :questionnaire_id, :integer
  end

  def down
  	remove_column :sections, :questionnaire_id, :integer
  end
end
