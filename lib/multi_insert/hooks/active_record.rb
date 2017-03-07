require 'active_record'
require 'multi_insert/query'

class ActiveRecord::Base
  def self.multi_insert(columns, values, opts = {})
    ::MultiInsert::Query.new(table_name, columns, values, opts)
  end
end
