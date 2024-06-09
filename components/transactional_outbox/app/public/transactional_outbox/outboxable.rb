# frozen_string_literal: true

module TransactionalOutbox
  # Outboxable
  module Outboxable
    extend ActiveSupport::Concern

    included do
      attr_accessor :outbox_event

      *namespace, klass = name.underscore.upcase.split('/')
      namespace = namespace.reverse.join('.')

      module_parent.const_set('Events', Module.new) unless module_parent.const_defined?('Events')

      { create: 'CREATED', update: 'UPDATED', destroy: 'DESTROYED' }.each do |key, value|
        const_name = "#{klass}_#{value}"

        unless module_parent::Events.const_defined?(const_name)
          module_parent::Events.const_set(const_name, "#{const_name}#{namespace.blank? ? '' : '.'}#{namespace}")
        end

        event_name = module_parent::Events.const_get(const_name)

        send("after_#{key}") { create_outbox!(key, event_name) }
      end
    end

    def save(**options, &)
      @outbox_event = options[:outbox_event]&.underscore&.upcase if options.present? && options.key?(:outbox_event)

      super
    end

    def save!(**options, &)
      @outbox_event = options[:outbox_event]&.underscore&.upcase if options.present? && options.key?(:outbox_event)

      super
    end

    private

    def create_outbox!(action, event_name) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      unless self.class.module_parent.const_defined?('OUTBOX_MODEL')
        *namespace, _ = self.class.name.underscore.upcase.split('/')
        namespace.reverse.join('.')
        outbox_model_name = TransactionalOutbox.configuration.outbox_mapping[self.class.module_parent.name]
        outbox_model = outbox_model_name&.safe_constantize || TransactionalOutbox::Outbox
        self.class.module_parent.const_set('OUTBOX_MODEL', outbox_model)
      end

      outbox = self.class.module_parent.const_get('OUTBOX_MODEL').new(
        aggregate: self.class.name,
        aggregate_identifier: try(:identifier) || id || nil,
        event: @outbox_event || event_name,
        identifier: SecureRandom.uuid,
        payload: payload(action)
      )
      @outbox_event = nil

      if outbox.invalid?
        outbox.errors.each do |error|
          errors.import(error, attribute: "outbox.#{error.attribute}")
        end
      end

      outbox.save!
    end

    def payload(action) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      payload = { before: nil, after: nil }
      case action
      when :create
        payload[:after] = as_json
      when :update
        # previous_changes => { 'name' => ['bob', 'robert']  }
        changes = previous_changes.transform_values(&:first)
        payload[:before] = as_json.merge(changes)
        payload[:after] = as_json
      when :destroy
        payload[:before] = as_json
      else
        raise ActiveRecord::RecordNotSaved.new("Failed to create Outbox payload for #{self.class.name}: #{identifier}",
                                               self)
      end
      payload
    end
  end
end
