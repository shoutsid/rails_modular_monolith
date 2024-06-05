# frozen_string_literal: true

module Ollama
  class MessagesInvalidError < StandardError
    # Custom error class raised when messages are invalid
  end

  # The ChatService class is used to chat to Ollama via the API
  class ChatService
    attr_reader :conversation_id, :event_payload, :client, :model
    attr_accessor :last_message
    attr_writer :messages

    # Initializes a new instance of the ChatService class.
    #
    # @param event_payload [Hash | HashWithIndifferentAccess] containing the event payload data.
    def initialize(event_payload) # rubocop:disable Metrics/AbcSize
      @event_payload = event_payload.with_indifferent_access
      @conversation_id = @event_payload['conversation_id'] unless @event_payload['conversation_id'].nil?
      @_messages = @event_payload['messages'] unless @event_payload['messages'].nil?
      @model = @event_payload['model'].nil? ? Ollama::Chat::DEFAULT_MODEL : @event_payload['model']
      @client = if !@event_payload['client'].nil? && @event_payload['client'] == 'langchain'
                  Langchain::LLM::Ollama.new(url: 'http://ollama:11434')
                else
                  Ollama.new(credentials: { address: 'http://ollama:11434' }, options: { server_sent_events: true })
                end

      memoization_and_validation
    end

    # Memoizes all required attributes and raises required exceptions.
    def memoization_and_validation
      conversation
      messages
    end

    # Calls the chat service with the provided client, messages, and conversation.
    def call
      Ollama::Chat.new(client:, messages:, conversation:).chat(model:)
    end

    private

    attr_reader :ollama_client

    # Retrieves the conversation associated with the current instance.
    # If the conversation_id is present and is an integer,
    # it will find the conversation with that ID. Otherwise, it creates a new conversation.
    #
    # @return [Ollama::Conversation] the conversation associated with the current instance.
    def conversation
      is_int = !conversation_id.nil? && conversation_id.is_a?(Integer)
      @conversation ||= (is_int && Ollama::Conversation.find(conversation_id)) || Ollama::Conversation.create!
    end

    # Retrieves the messages associated with the current instance.
    # Validates the structure of the messages and raises an error
    # if the messages are not in the correct format.
    #
    # @return [Array<Hash>] the messages associated with the current instance.
    def messages
      return @messages if messages_is_array?(@messages) && validate!(@messages)

      validate!(@_messages) if @messages.is_a?(Array)
      @messages = @_messages || []
    end

    # Validates the structure of the provided messages.
    # Raises an error if the messages are not an array or do not have the correct structure.
    #
    # @param msgs [Array<Hash>] the messages to validate.
    # @raise [Ollama::MessagesInvalidError] if the messages are not in the correct format.
    def validate!(msgs)
      raise(Ollama::MessagesInvalidError, 'messages provided should be an Array') unless messages_is_array?(msgs)

      unless messages_valid_structure?(msgs)
        raise(Ollama::MessagesInvalidError,
              "messages should be in the valid structure.For example: => [{role: 'user', content: 'content here'}]")
      end

      true
    end

    # Checks if the provided messages are an array.
    #
    # @param msgs [Object] the messages to check.
    # @return [Boolean] true if messages are an array, false otherwise.
    def messages_is_array?(msgs)
      !!msgs && msgs.is_a?(Array)
    end

    # Checks if the provided messages are an empty array.
    #
    # @param msgs [Array<Hash>] the messages to check.
    # @return [Boolean] true if messages are an empty array, false otherwise.
    def messages_empty?(msgs)
      messages_is_array?(msgs) && msgs.empty?
    end

    # Checks if the provided messages have a valid structure.
    # Each message should be a Hash or HashWithIndifferentAccess containing 'role' and 'content' keys.
    #
    # @param msgs [Array<Hash>] the messages to check.
    # @return [Boolean] true if messages have a valid structure, false otherwise.
    def messages_valid_structure?(msgs)
      msgs.all? { |m| m.is_a?(Hash) || m.is_a?(ActiveSupport::HashWithIndifferentAccess) } &&
        msgs.all? { |me| !!me['role'] && !!me['content'] }
    end
  end
end
