# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_30_171707) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "article_ratings", force: :cascade do |t|
    t.bigint "article_id"
    t.integer "mark", limit: 2
    t.index ["article_id"], name: "index_article_ratings_on_article_id"
  end

  create_table "articles", force: :cascade do |t|
    t.text "user_login", null: false
    t.text "title", null: false
    t.string "content", null: false
    t.cidr "user_ip", null: false
    t.decimal "rate", precision: 5, scale: 2, default: "0.0"
    t.integer "votes", default: 0
  end

  create_table "stat_ip_users", force: :cascade do |t|
    t.cidr "ip", null: false
    t.string "users", array: true
  end

  create_table "users", force: :cascade do |t|
    t.string "user_login"
  end

  create_trigger("articles_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("articles").
      after(:insert) do
    <<-SQL_ACTIONS
          update stat_ip_users
          set users = (select array_agg(distinct test) from unnest(users || string_to_array(NEW.user_login, '~')::varchar[]) test)
          where not users @> string_to_array(NEW.user_login, '~')::varchar[] and ip = NEW.user_ip;

          insert into stat_ip_users(ip, users)
          select NEW.user_ip, string_to_array(NEW.user_login, '~')::varchar[]
          where not exists (select 1 from stat_ip_users where ip = NEW.user_ip);
    SQL_ACTIONS
  end

end
