class CreateArticleRatingsTable < ActiveRecord::Migration[5.2]

  TABLE_NAME = :article_ratings

  def up
    create_table TABLE_NAME do |t|
      t.references :article
      t.integer :mark, limit: 1
    end
  end

  def down
    drop_table(TABLE_NAME) if table_exists?(TABLE_NAME)
  end

end
