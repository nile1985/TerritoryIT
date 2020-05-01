class Article < ApplicationRecord
  belongs_to :user, primary_key: :user_login, foreign_key: :user_login
end