class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    grab_id = <<-SQL
      SELECT last_insert_rowid() FROM dogs
    SQL

    @id = DB[:conn].execute(grab_id)[0][0]
    self
  end

  def self.create(attrs)
    new_dog = self.new(attrs)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    new_dog_values = DB[:conn].execute(sql, id).first
    new_dog = self.new_from_db(new_dog_values)
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    new_dog_values = DB[:conn].execute(sql, name, breed)
    return self.new_from_db(new_dog_values.first) unless new_dog_values.empty?
    self.create(name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    new_dog_values = DB[:conn].execute(sql, name).first
    new_dog = self.new_from_db(new_dog_values)
    new_dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
