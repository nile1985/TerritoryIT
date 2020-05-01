class CreateArticlesTable < ActiveRecord::Migration[5.2]

  TABLE_NAME = :articles

  def up
    create_table TABLE_NAME do |t|
      t.text :user_login, null: false
      t.text :title, null: false
      t.string :content, null: false
      t.cidr :user_ip, null: false
      t.decimal :rate, precision: 5, scale: 2, default: 0.0
      t.integer :votes, limit: 3, default: 0
    end
  end

  def down
    drop_table(TABLE_NAME) if table_exists?(TABLE_NAME)
  end

end
