require 'active_record'

module MultiInsert
  module QueryBuilder
    INSERT_DEFAULTS = {
      time: true
    }

    def self.insert(table, columns, values, opts = {})
      ar = ActiveRecord::Base.connection

      opts = INSERT_DEFAULTS.merge(opts)

      now = Time.now.to_s(:db) if opts[:time]
      table = ar.quote_table_name(table.to_s)

      # Format columns
      columns = columns + [:created_at, :updated_at] if opts[:time]
      columns = columns.map!{|c| ar.quote_column_name(c.to_s)}
      columns = join_params(columns)

      # Format values
      if opts[:time]
        values = values.map{|v| v + [now, now]}
      end
      values = values.map{|v| join_params(v.map{|vv| ar.quote(vv)})}.join(',')

      "INSERT INTO #{table} #{columns} VALUES #{values}"
    end

    def self.returning(columns)
      columns = columns.map{|c| ActiveRecord::Base.connection.quote_column_name(c.to_s)}.join(',')
      "RETURNING #{columns}"
    end

    def self.on_conflict(column)
      column = ActiveRecord::Base.connection.quote_column_name(column.to_s)
      "ON CONFLICT (#{column})"
    end

    def self.on_conflict_do_nothing(column)
      "#{on_conflict(column)} DO NOTHING"
    end

    def self.on_conflict_do_update(column, values, opts = {})
      opts = INSERT_DEFAULTS.merge(opts)
      if values.is_a?(Symbol) || values.is_a?(String)
        values = { values => :excluded }
      elsif values.is_a?(Array)
        values = values.product([:excluded]).to_h
      end
      if opts[:time]
        now = Time.now.to_s(:db)
        values[:updated_at] = now
      end
      arr = []
      values.each do |key, value|
        v = nil
        key = ActiveRecord::Base.connection.quote_column_name(key.to_s)
        if value == :excluded
          v = "excluded.#{key}"
        else
          v = ActiveRecord::Base.connection.quote(value)
        end
        arr << "#{key} = #{v}"
      end
      values = arr.join(', ')
      "#{on_conflict(column)} DO UPDATE SET #{values}"
    end

    def self.join_params(params)
      "(" + params.join(',') + ")"
    end
  end
end
