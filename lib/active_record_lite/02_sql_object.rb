require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'
require 'active_record'

class MassObject
  def self.parse_all(results)
    results.map { |object| self.new(object) }
  end
end

class SQLObject < MassObject
  def self.columns
    #returns array of column names as strings
    cols = DBConnection.execute2("SELECT * FROM #{self.table_name}")[0]
    cols.each do |col|
      define_method(col) do
        self.attributes[col]
      end
    
      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end
    end
    
    @columns = cols.map(&:to_sym)
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    #fetch all records from the database
    #raw hash { column names => [values] }
    search_results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    
    parse_all(search_results)
  end

  def self.find(id)
    #return a single object with the given id
    result = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = #{id}
    SQL
    
    parse_all(result).first
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * self.class.columns.length).join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute #{attr_name}"
      end
    end
  end

  def save
    self.id ? self.update : self.insert
  end

  def update
    set_line = self.class.columns.map { |attr| "#{attr} = ?"}.join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = #{self.id}
    SQL
  end

  def attribute_values
    self.class.columns.map { |attr| self.send(attr) }
  end
end