class AssociateUsers < Migrations::MongodbToPostgresql

  def self.up
    # Migrate the companies...
    sql = "UPDATE users SET company_id = companies.id FROM companies WHERE companies.legacy_id = users.legacy_company_id"
    postgre.create_command(sql).execute_non_query
  end

  def self.down
    sql = "UPDATE users SET company_id = NULL"
    postgre.create_command(sql).execute_non_query
  end
end
