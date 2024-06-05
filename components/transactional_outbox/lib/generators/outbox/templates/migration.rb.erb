class OutboxCreate<%= table_name.camelize.singularize %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :<%= table_name %> do |t|
      t.uuid :identifier, null: false, index: { unique: true }
      t.string :event, null: false
      t.jsonb :payload
      t.string :aggregate, null: false
      t.uuid :aggregate_identifier, null: true, index: true

      t.timestamps
    end


    create_table :<%= table_name.underscore %>_consumed_messages do |t|
      t.uuid :event_id
      t.string :aggregate


      t.integer :status, default: 0, null: false
      t.timestamps
    end

    add_index :<%= table_name.underscore %>_consumed_messages, [:event_id, :aggregate], unique: true, name: 'index_<%= table_name %>_event_id_and_agg'
    add_index :<%= table_name.underscore %>_consumed_messages, :status, name: 'index_<%= table_name %>_status'
  end
end
