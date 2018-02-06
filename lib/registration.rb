class Registration
  attr_accessor :id, :course_id, :student_id
	
  def self.create_table
    create = "CREATE TABLE IF NOT EXISTS registrations (id INTEGER PRIMARY KEY, course_id INTEGER, student_id INTEGER);"
    DB[:conn].execute(create)
  end

  def self.drop_table
    drop = "DROP TABLE IF EXISTS registrations;"
    DB[:conn].execute(drop)
  end
end