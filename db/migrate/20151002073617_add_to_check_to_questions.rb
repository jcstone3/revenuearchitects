class AddToCheckToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :to_check, :integer, :default => 0
  end
end
