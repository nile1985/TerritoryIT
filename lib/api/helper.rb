module Api
  class Helper

    def self.ips_users_list
      ActiveRecord::Base.connection.execute('select host(ip) as ip, users
        from stat_ip_users
        where cardinality(users) > 1').map { |rec| { ip: rec['ip'], users: rec['users'][1..-2].split(',')} }
    end

  end
end