class RenameUsernameToNickname < ActiveRecord::Migration
  def up
    rename_column :users, :username, :nickname
  end

  def down
    rename_column :users, :nickname, :username
  end
end
