require 'active_record'
require 'multi_insert/query_builder'

# Top level module for MultiInsert.
module MultiInsert
  # A MultiInsert query.
  #
  # Most of the time, you do not need to instanciate it yourself.
  class Query
    # A conflict close inside a query.
    #
    # You never need to instanciate it yourself. Instead, use `Query#on_conflict`.
    class OnConflict
      # Create an ON CONFLICT clause
      #
      # @param query [Query] the query.
      # @param column [String | Symbol | nil] the column to watch for conflicts.
      def initialize(query, column)
        @query = query
        @column = column
      end

      # Ignore conflicting rows.
      #
      # @return [Query] the original query.
      def do_nothing
        @query.on_conflict_sql(::MultiInsert::QueryBuilder.on_conflict_do_nothing(@column))
      end

      # Update the conflicting rows according to user-supplied rules.
      #
      # The rules can be:
      # - A single symbol or string denoting a column name. In this case, the matching column will be updated.
      # - An array of strings or symbols. In this case, the matching columns will be updated.
      # - An hash of values (Integers or Strings) or the symbol `:excluded`. The matching columns will be updated
      # to the supplied values, except when the value is `:excluded`. In that case, the matching columns will be set
      # to the value to be inserted.
      #
      # @param values [String | Symbol | Array<String | Symbol> | Hash<String | Symbol => String | Number | Boolean>] The user specified rules.
      # @return [Query] The original query.
      def do_update(values)
        @query.on_conflict_sql(::MultiInsert::QueryBuilder.on_conflict_do_update(@column, values, @query.opts))
      end
    end

    attr_reader :opts

    # Create an insert query against the specified table and columns, with the specified values.
    # The following options are supported:
    # - time (true) Whether to insert created_at and updated_at.
    #
    # @param table [String | Symbol] The table to be used for insertion.
    # @param columns [Array<String | Symbol>] The columns to be inserted.
    # @param values [Array<Array<String | Number | Boolean>>] The values to be inserted.
    # @param opts [Hash<Object>] Options.
    def initialize(table, columns, values, opts = {})
      @table = table.to_sym
      @opts = opts
      @sql_insert = ::MultiInsert::QueryBuilder.insert(table, columns, values, opts)
    end

    # Add a returning clause to the query.
    #
    # @param columns [Array<Symbol | String>] The columns to return.
    # @return [Query] self.
    def returning(columns)
      @sql_returning = ::MultiInsert::QueryBuilder.returning(columns)
      @returning_flat = false
      self
    end

    # Add a returning clause to the query, returning IDs.
    #
    # The IDs will be returned as a flat array.
    # @return [Query] self
    def returning_id
      @sql_returning = ::MultiInsert::QueryBuilder.returning([:id])
      @returning_flat = true
      self
    end

    # Begin a conflict clause.
    #
    # @param column [String | Symbol] The column to watch for conflicts.
    # @return [Query::OnConflict] A conflict clause.
    def on_conflict(column = nil)
      ::MultiInsert::Query::OnConflict.new(self, column)
    end

    # Handle a conflict with raw SQL
    #
    # You should probably use the friendly helper method instead.
    # @param sql [String] An SQL expression starting with "ON CONFLICT".
    # @return [Query] self.
    def on_conflict_sql(sql)
      @sql_on_conflict = sql
      self
    end

    # Convert the query to raw SQL.
    #
    # @return [String] An SQL query.
    def to_sql
      [@sql_insert, @sql_on_conflict, @sql_returning].reject(&:nil?).join(' ')
    end

    # Equivalent to `to_sql`.
    #
    # @return [String] An SQL query.
    def to_s
      to_sql
    end

    # Execute the query, and return eventual results.
    #
    # Result may be:
    # - Nil if no returning clause was present.
    # - An array of IDs if the returning_id helper was called.
    # - An array of rows otherwise.
    #
    # @return [nil | Array<Integer> | Array<Array<String | Number | Boolean>>]
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
