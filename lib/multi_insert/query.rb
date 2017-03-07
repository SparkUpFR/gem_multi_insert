require 'active_record'
require 'multi_insert/query_builder'

module MultiInsert
  class Query
    class OnConflict
      def initialize(query, column)
        @query = query
        @column = column.to_sym
      end

      def do_nothing
        @query.on_conflict_sql(::MultiInsert::QueryBuilder.on_conflict_do_nothing(@column))
      end

      def do_update(values)
        @query.on_conflict_sql(::MultiInsert::QueryBuilder.on_conflict_do_update(@column, values, @query.opts))
      end
    end

    attr_reader :opts

    def initialize(table, columns, values, opts = {})
      @table = table.to_sym
      @opts = opts
      @sql_insert = ::MultiInsert::QueryBuilder.insert(table, columns, values, opts)
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

    def on_conflict(column)
      ::MultiInsert::Query::OnConflict.new(self, column)
    end

    def on_conflict_sql(sql)
      @sql_on_conflict = sql
      self
    end

    def to_sql
      [@sql_insert, @sql_on_conflict, @sql_returning].reject(&:nil?).join(' ')
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
          result.values.map{|r| r.first}
        else
          result
        end
      end
    end
  end
end
