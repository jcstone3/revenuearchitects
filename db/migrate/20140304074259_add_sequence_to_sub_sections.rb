class AddSequenceToSubSections < ActiveRecord::Migration
  def change
    add_column :sub_sections, :sequence, :integer
  end
end
