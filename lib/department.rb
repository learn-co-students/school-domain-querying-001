class Department

attr_accessor :id, :name

def initialize
end

def self.drop_table
  DB[:conn].execute("DROP TABLE IF EXISTS departments;")
  end 

def self.create_table
  Department.drop_table
  sql = "CREATE TABLE departments
  (id INTEGER PRIMARY KEY,
  name TEXT);"
  DB[:conn].execute(sql)
end

def insert
  sql_insert = "INSERT INTO departments (name) VALUES (?)"
  sql_get_id = "SELECT id FROM departments ORDER BY id DESC LIMIT 1"


  DB[:conn].execute(sql_insert, [@name])
  self.id = DB[:conn].execute(sql_get_id)[0][0]
end

def self.new_from_db(row)
  new_department = Department.new
  new_department.id = row[0]
  new_department.name = row[1]
  new_department
end


def self.find_by_name(name)
  sql = "SELECT * FROM departments WHERE name = ?;"
  new_department = DB[:conn].execute(sql, name)[0]
  if new_department == nil then
    nil
  else
    Department.new_from_db(new_department)
  end
end

def self.find_by_id(find_id)
  sql = "SELECT * FROM departments WHERE id = ?;"
  new_department = DB[:conn].execute(sql, find_id)[0]
  if new_department == nil then
    nil
  else
    Department.new_from_db(new_department)
  end
end

def update
  sql = "UPDATE departments SET name = ? WHERE id = #{self.id}"
  DB[:conn].execute(sql, @name)
end

def save
  if self.id == nil then
    self.insert
  else
    self.update
  end
end

def add_course(course)
  sql = "UPDATE courses SET department_id = ? WHERE id = #{course.id}"
  DB[:conn].execute(sql, @id)
end

def courses
  sql = "SELECT name FROM courses WHERE department_id = ?"
  course_array = []
  DB[:conn].execute(sql, @id).each do |course|
    course_array << Course.find_by_name(course)
  end
  course_array
end


end
