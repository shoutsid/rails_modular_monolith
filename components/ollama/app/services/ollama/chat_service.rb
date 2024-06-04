module Ollama
  class MessagesInvalidError < StandardError
    # Custom error class raised when messages are invalid
  end

  class ChatService
    attr_reader :conversation_id, :event_payload, :client, :model
    attr_accessor :messages, :last_message

    # Initializes a new instance of the ChatService class.
    #
    # @param event_payload [Hash | HashWithIndifferentAccess] containing the event payload data.
    def initialize(event_payload)
      @event_payload = event_payload.with_indifferent_access
      @conversation_id = @event_payload.dig('conversation_id') if !!@event_payload.dig('conversation_id')
      @_messages = @event_payload.dig('messages') if !!@event_payload.dig('messages')
      @model = !!@event_payload.dig('model') ? @event_payload.dig('model') : Ollama::Chat::DEFAULT_MODEL
      @client = ::Ollama.new(
        credentials: { address: 'http://ollama:11434' },
        options: { server_sent_events: true }
      )

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

    # Retrieves the conversation associated with the current instance. If the conversation_id is present and is an integer,
    # it will find the conversation with that ID. Otherwise, it creates a new conversation.
    #
    # @return [Ollama::Conversation] the conversation associated with the current instance.
    def conversation
      is_int = conversation_id.present? && conversation_id.is_a?(Integer)
      @conversation ||= ((is_int && Ollama::Conversation.find(conversation_id)) || Ollama::Conversation.create!)
    end

    # Retrieves the messages associated with the current instance. Validates the structure of the messages and raises an error
    # if the messages are not in the correct format.
    #
    # @return [Array<Hash>] the messages associated with the current instance.
    def messages
      return @messages if messages_is_array?(@messages) && validate!(@messages)

      validate!(@_messages) if @messages.kind_of?(Object)
      @messages = @_messages
    end

    # Validates the structure of the provided messages. Raises an error if the messages are not an array or do not have the correct structure.
    #
    # @param messages [Array<Hash>] the messages to validate.
    # @raise [Ollama::MessagesInvalidError] if the messages are not in the correct format.
    def validate!(_messages)
      raise(Ollama::MessagesInvalidError, 'messages provided should be an Array') unless messages_is_array?(_messages)

      unless messages_valid_structure?(_messages)
        raise(Ollama::MessagesInvalidError, "messages should be in the valid structure.For example: => [{role: 'user', content: 'content here'}]")
      end

      true
    end

    # Checks if the provided messages are an array.
    #
    # @param messages [Object] the messages to check.
    # @return [Boolean] true if messages are an array, false otherwise.
    def messages_is_array?(_messages)
      !!_messages && _messages.is_a?(Array)
    end

    # Checks if the provided messages are an empty array.
    #
    # @param messages [Array<Hash>] the messages to check.
    # @return [Boolean] true if messages are an empty array, false otherwise.
    def messages_empty?(_messages)
      messages_is_array?(_messages) && _messages.empty?
    end

    # Checks if the provided messages have a valid structure. Each message should be a Hash or HashWithIndifferentAccess containing 'role' and 'content' keys.
    #
    # @param messages [Array<Hash>] the messages to check.
    # @return [Boolean] true if messages have a valid structure, false otherwise.
    def messages_valid_structure?(_messages)
      _messages.all? { |e| e.is_a?(Hash) || e.is_a?(HashWithIndifferentAccess) } &&
        _messages.all? { |e| !!e.dig('role') && !!e.dig('content') }
    end
  end
end
