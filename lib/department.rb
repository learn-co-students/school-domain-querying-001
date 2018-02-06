class Department
	attr_accessor :id, :name

  def courses
    courses = Course.find_all_by_department_id(@id)
  end

  def add_course(course)
    course.department = self
  end

  def self.create_table
    create = "CREATE TABLE IF NOT EXISTS departments (id INTEGER PRIMARY KEY, name TEXT);"
    DB[:conn].execute(create)
  end

  def self.drop_table
    drop = "DROP TABLE IF EXISTS departments;"
    DB[:conn].execute(drop)
  end

  def insert
    db = DB[:conn]
    insert = db.prepare("INSERT INTO departments (name) VALUES (?);")
    rows = insert.execute(@name)
    @id = db.last_insert_row_id()
  end

  def update
    db = DB[:conn]
    update = db.prepare("UPDATE departments SET name = ? WHERE departments.id = ?;")
    update.execute(@name, @id)
  end

  def save
    if @id == nil
      self.insert
    else
      self.update
    end
  end

  def self.new_from_db(row)
    dept = Department.new()
    dept.id = row[0]
    dept.name = row[1]
    dept
  end

  def self.find_by_name(name)
    db = DB[:conn]
    find = db.prepare("SELECT * FROM departments WHERE departments.name = ?")
    results = find.execute(name).to_a
    
    if results != []
      Department.new_from_db(results[0])
    else
      nil
    end
  end

  def self.find_by_id(id)
    db = DB[:conn]
    find = db.prepare("SELECT * FROM departments WHERE departments.id = ?")
    results = find.execute(id).to_a
    
    if results != []
      Department.new_from_db(results[0])
    else
      nil
    end
  end
end
