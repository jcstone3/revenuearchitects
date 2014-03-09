class AddPopupStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :popup_status, :boolean, :default => true
  end
end
