require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]

      source_options = through_options.table_name

      through_table = through_options.table_name
      through_primary_key = through.primary_key
      through_foreign_key = through.foreign_key
      
      source_table = source_options.table_name
      source_primary_key = source.primary_key
      source_foreign_key = source.foreign_key
      result = DBConnection.execute(<<-SQL)
      
      
      SQL
      
      #parse results
    end
  end
end
