class Changeresponsedatatype < ActiveRecord::Migration
  def self.up
  rename_column :responses, :answer_1, :answer_1_string
  add_column :responses, :answer_1, :integer

  Response.reset_column_information
  Response.find_each { |res| res.update_attribute(:answer_1, res.answer_1_string) } 
  remove_column :responses, :answer_1_string
end
end
