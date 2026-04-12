class AddOwUserIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :ow_user_id, :string
    add_index :users, :ow_user_id, unique: true
  end
end
