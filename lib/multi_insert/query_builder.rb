require 'active_record'

module MultiInsert
  module QueryBuilder
    def self.insert(table, columns, values, opts = {})
      ar = ActiveRecord::Base.connection

      options = {time: true}
      options.merge!(opts)

      now = Time.now.to_s(:db) if options[:time]
      table = ar.quote_table_name(table.to_s)

      # Format columns
      columns = columns + [:created_at, :updated_at] if options[:time]
      columns = columns.map!{|c| ar.quote_column_name(c.to_s)}
      columns = join_params(columns)

      # Format values
      if options[:time]
        values = values.map{|v| v + [now, now]}
      end
      values = values.map{|v| join_params(v.map{|vv| ar.quote(vv.to_s)})}.join(',')

      "INSERT INTO #{table} #{columns} VALUES #{values}"
    end
  end

  def self.returning(columns)
    columns = columns.map{|c| ActiveRecord::Base.connection.quote_column_name(c.to_s)}.join(',')
    "RETURNING #{columns}"
  end

  def self.join_params(params)
    "(" + params.join(',') + ")"
  end
end
