class CreateUsersTable < ActiveRecord::Migration[5.2]

  TABLE_NAME = :users

  def up
    create_table TABLE_NAME do |t|
      t.string :user_login, unique: true
    end
  end

  def down
    drop_table(TABLE_NAME) if table_exists?(TABLE_NAME)
  end

end
