require 'active_record'
require 'multi_insert/query_builder'

module MultiInsert
  class Query
    def initialize(table, columns, values, opts = {})
      @table = table.to_sym
      @sql_insert = ::MultiInsert::QueryBuilder.insert(table, columns, values, opts = {})
    end

    def returning(columns)
      @sql_returning = ::MultiInsert::QueryBuilder.returning(columns)
      @returning_flat = false
      self
    end

    def returning_id
      @sql_returning = ::MultiInsert::QueryBuilder.returning([:id])
      @returning_flat = true
      self
    end

    def to_sql
      sql = @sql_insert
      sql = "#{sql} #{@sql_returning}" unless @sql_returning.nil?
      sql
    end

    def to_s
      to_sql
    end

    def execute
      result = ActiveRecord::Base.connection.execute(to_sql)
      if @sql_returning.nil?
        nil
      else
        if @returning_flat
          result.rows.map{|r| r.first}
        else
          result
        end
      end
    end
  end
end
