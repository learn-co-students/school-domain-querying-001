class Course
require 'pry'

attr_accessor :id, :name, :department_id, :students

def initialize
end

def self.drop_table
  DB[:conn].execute("DROP TABLE IF EXISTS courses;")
  end 

def self.create_table
  Course.drop_table
  sql = "CREATE TABLE courses 
  (id INTEGER PRIMARY KEY,
  name TEXT,
  department_id INTEGER);"
  DB[:conn].execute(sql)
end

def insert
  sql_insert = "INSERT INTO courses (name, department_id) VALUES (?, ?)"
  sql_get_id = "SELECT id FROM courses ORDER BY id DESC LIMIT 1"


  DB[:conn].execute(sql_insert, [@name, @department_id])
  self.id = DB[:conn].execute(sql_get_id)[0][0]
end

def self.new_from_db(row)
  new_course = Course.new
  new_course.id = row[0]
  new_course.name = row[1]
  new_course.department_id = row[2]
  new_course
end

def self.find_by_name(name)
  sql = "SELECT * FROM courses WHERE name = ?;"
  new_course = DB[:conn].execute(sql, name)[0]
  if new_course == nil then
    nil
  else
    Course.new_from_db(new_course)
  end
end

def self.find_all_by_department_id(id_search)
  sql = "SELECT * FROM courses WHERE department_id = ?;"
  new_course = DB[:conn].execute(sql, id_search)[0]
  Course.new_from_db(new_course)
end

def update
  sql = "UPDATE courses SET name = ?, department_id = ? WHERE id = #{self.id}"
  DB[:conn].execute(sql, @name, @department_id)
end

def save
  if self.id == nil then
    self.insert
  else
    self.update
  end
end

def department=(department)
  @department = department
  @department_id = department.id
  department.add_course(self)
end

def department
  Department.find_by_id(@department_id)
end

def add_student(student)
  if @students == nil
    @students = []
    @students << student
  else
    @students << student  
  end
end




end
