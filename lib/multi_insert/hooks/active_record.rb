require 'active_record'
require 'multi_insert/query'

class ActiveRecord::Base
  def self.multi_insert(columns, values)
    ::MultiInsert::Query.new(table_name, columns, values)
  end
end
