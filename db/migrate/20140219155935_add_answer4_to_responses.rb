class AddAnswer4ToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :answer_4, :integer
  end
end
