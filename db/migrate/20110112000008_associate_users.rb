class AssociateUsers < Migrations::MongodbToPostgresql

  def self.up
    # Migrate the companies...
    subselect = "SELECT id FROM companies WHERE legacy_id = legacy_company_id"
    sql = "UPDATE users SET company_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query
  end

  def self.down
    sql = "UPDATE users SET company_id = NULL"
    postgre.create_command(sql).execute_non_query
  end
end
