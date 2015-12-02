
class Course

  attr_accessor :id, :name, :department_id

  def self.create_table
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS courses (
      id INTEGER PRIMARY KEY,
      name TEXT,
      department_id INTEGER)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS courses"
    DB[:conn].execute(sql)
  end

  def attribute_values
    [name, department_id]
  end


  def insert
    sql = <<-SQL 
    INSERT INTO courses (name, department_id)
    VALUES (?,?)
    SQL
    DB[:conn].execute(sql, attribute_values)
    @id = DB[:conn].execute("SELECT last_insert_rowid() from courses").first[0]
  end

  def self.new_from_db (row)
    new_course = Course.new
    new_course.id = row[0]
    new_course.name = row[1]
    new_course.department_id = row[2]
    new_course
  end

  def self.find_by_name (name)
    sql = <<-SQL
    SELECT * FROM courses WHERE name = ? LIMIT 1
    SQL
    nm = DB[:conn].execute(sql, name)[0]
    Course.new_from_db(nm) if nm
  end

  def self.find_all_by_department_id (dep_id)
    sql = <<-SQL
    SELECT * FROM courses WHERE department_id = ?
    SQL
    di = DB[:conn].execute(sql, dep_id)
    di.collect {|row| Course.new_from_db(row)}
  end

  def update
    sql = <<-SQL
    UPDATE courses
    SET name = ?, department_id = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, attribute_values, self.id)
  end

  def save
    self.id ? update : insert
  end

  def department
  
  Department.find_by_id(self.department_id)
 
  end

  def department=(dep)
    
    dp = Department.find_by_name(dep.name)
    
    self.department_id = dp.id if dp

  end

  def students
    #find all students by course_id
    sql = <<-SQL
    SELECT students.*
    FROM courses
    JOIN registrations
    ON courses.id = registrations.course_id
    JOIN students
    ON students.id = registrations.student_id
    WHERE courses.id = ?
    SQL
    result = DB[:conn].execute(sql, self.id)
    result.map do |row|
    Course.new_from_db(row)
    end
  end

  def add_student(student)
  #add a student to a particular course and save them
    sql = "INSERT INTO registrations (course_id, student_id) VALUES (?,?);"
    DB[:conn].execute(sql, self.id, student.id)
  end
end
