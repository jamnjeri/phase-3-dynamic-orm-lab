require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    # Table creation
    def self.table_name
        self.to_s.downcase.pluralize
    end

    # Column names
    def self.column_names
        DB[:conn].results_as_hash = true
    
        sql = "pragma table_info('#{table_name}')"
    
        table_info = DB[:conn].execute(sql)
        column_names = []
        table_info.each do |row|
          column_names << row["name"]
        end
        column_names.compact
    end

    # Initialization
    def initialize(options={})
        options.each do |property, value|
          self.send("#{property}=", value)
        end
    end

    # Table name for insert
    def table_name_for_insert
        self.class.table_name
    end

    # Column name for insert
    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    # Values for insert
    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
          values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    # Save
    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    # Find by name
    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
        DB[:conn].execute(sql, name)
    end

    # Find by
    def self.find_by(attribute_hash)
        value = attribute_hash.values.first
        formatted_value = value.class == Fixnum ? value : "'#{value}'"
        sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
        DB[:conn].execute(sql)
    end


end