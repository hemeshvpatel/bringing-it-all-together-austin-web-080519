class Dog
    attr_accessor :name, :breed, :id

    def initialize(attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)}
    end

    def self.create_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
        
        sql = <<-SQL
            CREATE TABLE dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def self.new_from_db(row)
        self.new(id:row[0],name:row[1],breed:row[2])
    end

    def update
        sql = <<-SQL
          UPDATE dogs 
          SET name = ?, breed = ? 
          WHERE id = ?
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        if self.id
          self.update
        else
        sql = <<-SQL
          INSERT INTO dogs(name, breed)
          VALUES (?, ?)
        SQL
    
        DB[:conn].execute(sql,self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
        end
    end

    def self.create(attributes)
        new_dog = Dog.new(attributes)
        new_dog.save
    end
    
    def self.find_by_id(dog_id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, dog_id).map {|row| self.new_from_db(row)}.first
    end

    def self.find_by_name(dog_name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
    
        DB[:conn].execute(sql, dog_name).map {|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = self.new(id:dog_data[0],name:dog_data[1],breed:dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

end