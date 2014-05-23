require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]

      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_primary_key = through_options.primary_key
      through_for_key = through_options.foreign_key
      
      source_table = source_options.table_name
      source_primary_key = source_options.primary_key
      source_for_key = source_options.foreign_key
      
      value = self.send(through_for_key)
      result = DBConnection.execute(<<-SQL, value)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_for_key} = #{source_table}.#{source_primary_key}
        WHERE
          #{through_table}.#{through_primary_key} = ?
      SQL
      
      source_options.model_class.parse_all(result).first
    end
  end
end
