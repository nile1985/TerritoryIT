class CreateTriggerArticlesInsert < ActiveRecord::Migration[5.2]

  def up
    create_trigger('articles_after_insert_row_tr', generated: true, compatibility: 1).on('articles').
      after(:insert) do
        <<-SQL_ACTIONS
          update stat_ip_users
          set users = (select array_agg(distinct test) from unnest(users || string_to_array(NEW.user_login, '~')::varchar[]) test)
          where not users @> string_to_array(NEW.user_login, '~')::varchar[] and ip = NEW.user_ip;

          insert into stat_ip_users(ip, users)
          select NEW.user_ip, string_to_array(NEW.user_login, '~')::varchar[]
          where not exists (select 1 from stat_ip_users where ip = NEW.user_ip)
        SQL_ACTIONS
      end
  end

  def down
    drop_trigger('articles_after_insert_row_tr', 'articles', generated: true)
  end
end
