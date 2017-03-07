require 'active_record'
require 'multi_insert/query'

class ActiveRecord::Base
  # Start a multi insert.
  #
  # See `Query#new` for a list of options.
  #
  # @param columns [Array<Symbol | String>] The columns to use for insertion.
  # @param values [Array<Array<String | Number | Boolean | nil>>] Values to be inserted.
  # @param opts [Hash<Object>] Options.
  # @return [Query] A query object.
  def self.multi_insert(columns, values, opts = {})
    ::MultiInsert::Query.new(self.table_name, columns, values, opts)
  end
end
