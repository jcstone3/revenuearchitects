class CreateSubSections < ActiveRecord::Migration
  def change
    create_table :sub_sections do |t|
      t.string :name, :limit => 150
      t.string :description, :limit => 500
      t.string :order, :limit => 100
      t.boolean :is_active
      t.integer :section_id
      t.timestamps
    end
  end
end
