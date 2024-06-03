require 'rails/generators/active_record'
module Outbox
  class OutboxGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    class_option :root_components_path, type: :string, default: Rails.root.to_s

    def create_migration_files
      migration_path = "#{options['root_components_path']}/db/#{name}_migrate"
      migration_template(
        "migration.rb",
        "#{migration_path}/outbox_create_#{table_name.singularize}.rb",
        migration_version: migration_version
      )

      template(
        'outbox.rb',
        "#{options['root_components_path']}/components/#{name}/app/models/#{name}/outbox.rb",
      )

      template(
        'consumed_message.rb',
        "#{options['root_components_path']}/components/#{name}/app/models/#{name}/consumed_message.rb",
      )

      template(
        'batch_consumer.rb',
        "#{options['root_components_path']}/components/#{name}/app/consumers/#{name}/batch_base_consumer.rb",
      )

      template(
        'outbox_consumer.rb',
        "#{options['root_components_path']}/components/#{name}/app/consumers/#{name}/outbox_consumer.rb",
      )
    end

    def migration_version
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    end

    def table_name
      "#{name}_outboxes"
    end
  end
end
