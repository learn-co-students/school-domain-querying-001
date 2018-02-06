require 'pry'

class Course
  attr_accessor :id, :name, :department_id

  def department=(department)
    @department_id = department.id
    self.save
  end

  def department
    if department_id == nil
      nil
    else
      Department.find_by_id(@department_id)
    end
  end

  def add_student(student)
    student.add_course(self)
  end

  def students
    sql = <<-SQL
    SELECT students.*
    FROM students
    JOIN registrations
    ON students.id = registrations.student_id
    JOIN courses
    ON courses.id = registrations.course_id
    WHERE courses.id = ?
    SQL
    result = DB[:conn].execute(sql, self.id)
    result.map do |row|
      Student.new_from_db(row)
    end
  end

  def self.create_table
    create = "CREATE TABLE IF NOT EXISTS courses (id INTEGER PRIMARY KEY, name TEXT, department_id INTEGER);"
    DB[:conn].execute(create)
  end

  def self.drop_table
    drop = "DROP TABLE IF EXISTS courses;"
    DB[:conn].execute(drop)
  end

  def insert
    db = DB[:conn]
    insert = db.prepare("INSERT INTO courses (name, department_id) VALUES (?, ?);")
    rows = insert.execute(@name, @department_id)
    @id = db.last_insert_row_id()
  end

  def update
    db = DB[:conn]
    update = db.prepare("UPDATE courses SET name = ?, department_id = ? WHERE courses.id = ?;")
    update.execute(@name, @department_id, @id)
  end

  def save
    if @id == nil
      self.insert
    else
      self.update
    end
  end

  def self.new_from_db(row)
    course = Course.new()
    course.id = row[0]
    course.name = row[1]
    course.department_id = row[2]
    course
  end

  def self.find_by_name(name)
    db = DB[:conn]
    find = db.prepare("SELECT * FROM courses WHERE courses.name = ?")
    results = find.execute(name).to_a
    
    if results != []
      Course.new_from_db(results[0])
    else
      nil
    end
  end

  def self.find_all_by_department_id(department_id)
    db = DB[:conn]
    find = db.prepare("SELECT * FROM courses WHERE courses.department_id = ?")
    results = find.execute(department_id).to_a
    results.map do |result|
      self.new_from_db(result)
    end
  end
end
