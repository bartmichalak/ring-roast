class AddOwUserIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :ow_user_id, :string, if_not_exists: true
  end
end
