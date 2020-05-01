class CreateStatIpUsersTable < ActiveRecord::Migration[5.2]

  TABLE_NAME = :stat_ip_users

  def up
    create_table TABLE_NAME do |t|
      t.cidr :ip, null: false
      t.string :users, array: true
    end
  end

  def down
    drop_table(TABLE_NAME) if table_exists?(TABLE_NAME)
  end

end
