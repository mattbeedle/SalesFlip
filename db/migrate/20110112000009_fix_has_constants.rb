class FixHasConstants < Migrations::MongodbToPostgresql

  def self.up
    puts 'fixing accounts access'
    sql = 'update accounts set access = access + 1 where access is not null'
    postgre.create_command(sql).execute_non_query

    puts 'fixing accounts account_type'
    sql = 'update accounts SET account_type = account_type + 1 where account_type is not null'
    postgre.create_command(sql).execute_non_query

    puts 'fixing activities action'
    sql = 'update activities SET action = action + 1 where action is not null'
    postgre.create_command(sql).execute_non_query

    %w(access title source salutation).each do |c|
      puts "fixing contacts #{c}"
      sql = "update contacts set #{c} = #{c} + 1 where #{c} is not null"
      postgre.create_command(sql).execute_non_query
    end

    puts 'fixing invitations role'
    sql = 'update invitations set role = role + 1 where role is not null'
    postgre.create_command(sql).execute_non_query

    %w(title salutation status source).each do |c|
      puts "fixing leads #{c}"
      sql = "update leads set #{c} = #{c} + 1 where #{c} is not null"
      postgre.create_command(sql).execute_non_query
    end

    puts 'fixing tasks category'
    sql = 'update tasks set category = category + 1 where category is not null'
    postgre.create_command(sql).execute_non_query

    puts 'fixing users role'
    sql = 'update users set role = role + 1 where role is not null'
    postgre.create_command(sql).execute_non_query
  end

  def self.down
  end
end
