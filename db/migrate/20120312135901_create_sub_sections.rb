class CreateSubSections < ActiveRecord::Migration
  def change
    create_table :sub_sections do |t|
      t.string :name
      t.string :description
      t.string :order
      t.boolean :is_active
      t.integer :section_id
      t.timestamps
    end
  end
end
