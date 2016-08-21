class Registration

  attr_accessor :id, :course_id, :student_id

def initialize
end

def self.drop_table
  DB[:conn].execute("DROP TABLE IF EXISTS registrations;")
  end 

def self.create_table
  Registration.drop_table
  sql = "CREATE TABLE registrations
  (id INTEGER PRIMARY KEY,
  course_id INTEGER,
  student_id INTEGER);"
  DB[:conn].execute(sql)
end
	
end