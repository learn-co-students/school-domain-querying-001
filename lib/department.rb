class Department
	attr_accessor :id, :name

  def self.create_table
    sql = <<-SQL
      CREATE TABLE  IF NOT EXISTS departments (id INTEGER PRIMARY KEY,
      name TEXT)
    SQL

    DB[:conn].execute(sql)

  end

  def self.drop_table
    sql = <<-SQL 
    DROP TABLE IF EXISTS departments
    SQL

    DB[:conn].execute(sql)
  end

  def insert
    sql = "INSERT INTO departments (name) VALUES (?)"
    DB[:conn].execute(sql, [self.name])

    @id = DB[:conn].execute("SELECT last_insert_rowid() from departments").first[0]

  end

  def self.new_from_db (row)
    self.new.tap do |new_dep|
    new_dep.id = row[0]
    new_dep.name = row[1]
    end
  end

  def self.find_by_name (dep_name)
    sql = <<-SQL
    SELECT * FROM departments WHERE name = ? LIMIT 1
    SQL
    nm = DB[:conn].execute(sql, dep_name)[0]
    self.new_from_db(nm) if nm
  end

  def self.find_by_id (id)
     sql = <<-SQL
      SELECT *
      FROM departments
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
    UPDATE departments
    SET name = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.id)
  end

  def save
    self.id ? update : insert
  end

  def courses
  #find all courses by department_id
   Course.find_all_by_department_id (self.id)
  end

  def add_course(course)
  #add a course to a department and save it
   course.department_id = self.id
   course.save
  end

  end
