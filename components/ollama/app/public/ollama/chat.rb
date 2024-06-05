# frozen_string_literal: true

require 'ollama-ai'

module Ollama
  class InvalidClient < StandardError
    # Custom error class raised when the client is invalid
  end

  class InvalidModelError < StandardError
    # Custom error class raised when models are invalid
  end

  class InvalidRoleError < StandardError
    # Custom error class raised when message roles are invalid
  end

  # Handles chatting with the AI model
  class Chat
    DEFAULT_MODEL = 'llama3'

    # The Chat class handles generating responses using the AI model.
    attr_writer :event_callback
    attr_reader :client, :conversation
    attr_accessor :messages, :last_message

    # Initializes a new instance of the Chat class.
    #
    # @param client [Ollama::Controllers::Client | Langchain::LLM::Ollama] AI client to use for generating responses.
    # @param messages [Array<Hash>] the messages in the conversation.
    # @param conversation [Ollama::Conversation] the conversation object associated with the chat.
    def initialize(client:, messages:, conversation:)
      @client = client
      @messages = messages
      @conversation = conversation
      @event_callback = event_callback
    end

    # Event callback to switch between valid clients
    #
    # @return [Proc] the callback to be used for event handling.
    def event_callback
      if ollama_controller_client?
        ollama_controller_client_callback
      elsif client.is_a?(Langchain::LLM::Ollama)
        langchain_event_callback
      else
        raise InvalidClient, 'the client provided is not of type Ollama::Controllers::Client or Langchain::LLM::Ollama'
      end
    end

    # Check to see if the client is of type Ollama::Controllers::Client
    #
    # @return [Boolean] true if the client is of type Ollama::Controllers::Client
    def ollama_controller_client?
      client.is_a?(Ollama::Controllers::Client)
    end

    # Event callback used for the Ollama::Controllers::Client
    #
    # @return [Proc] the callback to be used for event handling.
    def ollama_controller_client_callback
      lambda do |event, _raw|
        create_event(**event)
        if !!event['error'] && event['error'].include?('invalid role')
          raise InvalidRoleError,
                event['error']
        end
      end
    end

    # Event callback used for the Langchain::LLM::Ollama
    #
    # @return [Proc] the callback to be used for event handling.
    def langchain_event_callback
      lambda do |langchain_event|
        event = langchain_event.raw_response
        create_event(event)
        if !!event['error'] && event['error'].include?('invalid role')
          raise InvalidRoleError,
                event['error']
        end
      end
    end

    # Generates a response using the AI model with the given prompt.
    #
    # @param model [String] the AI model to use for generating the response.
    # @param prompt [String] the prompt to generate a response for.
    def generate(model: DEFAULT_MODEL, prompt: 'hi! please send me a long message')
      before(content: prompt)
      args = { model:, prompt: }
      ollama_controller_client? ? client.generate(args, &event_callback) : client.generate(**args, &event_callback)
      after
    rescue Ollama::Errors::RequestError, Faraday::ResourceNotFound => e
      raise e unless e.detailed_message.include?('status 404')

      rescue_from(e, args)
      retry
    end

    # Chats with the AI model using the given message.
    #
    # @param model [String] the AI model to use for generating the response.
    # @param message [String] the message to send to the AI model.
    def chat(model: DEFAULT_MODEL, message: 'hi! please send me a long message')
      before(content: message)
      args = { model:, messages: }
      ollama_controller_client? ? client.chat(args, &event_callback) : client.chat(**args, &event_callback)
      after
    rescue Ollama::Errors::RequestError, Faraday::ResourceNotFound => e
      raise e unless e.detailed_message.include?('status 404')

      rescue_from(e, args)
      retry
    end

    # Processes the given content before sending it to the AI model.
    #
    # @param content [String] the content to process.
    def before(content:)
      self.last_message = Ollama::Message.create!(role: 'user', content:, conversation:)
      messages << { role: 'user', content: }
    end

    # Processes the response from the AI model after it has been generated.
    def after # rubocop:disable Metrics/CyclomaticComplexity
      complete_response = last_message&.events&.pluck(:data)&.map do |e|
        content = e.dig('message', 'content')
        content || (e['response'] || '')
      end&.join
      self.last_message = Ollama::Message.create!(role: 'assistant', content: complete_response, conversation:)
      messages << { role: 'assistant', content: complete_response }
    end

    # Pulls the model passed from the AI service.
    # Otherwsie, uses the default model.
    # @param model [String] the AI model to use for generating the response.
    def pull_model(model: DEFAULT_MODEL)
      # Skip pulling a new model in test env.
      # We fall back to a safe client controller that we can pull from. Bypassing any that is passed.
      # At the time of implimentation of the pull endpoint Langchainrb does not include this feature.
      # Possible PR?
      #
      # https://github.com/patterns-ai-core/langchainrb/blob/main/lib/langchain/llm/ollama.rb
      # TODO: Use ENV here for client url
      return if Rails.env.test?

      clt = Ollama.new(credentials: { address: 'http://ollama:11434' }, options: { server_sent_events: true })
      clt.pull({ name: model }) do |event, _raw|
        raise InvalidModelError if !event['error'].nil? && event['error'].include?('file does not exist')

        print '.'
      end
    end

    private

    # Creates an event for the current conversation and message.
    #
    # @param event [Hash] the event data to create.
    def create_event(event)
      Ollama::Event.create!(data: event, message: last_message, conversation:)
    end

    # Rescues from a 404 error by pulling the 'llama3' model and regenerating the response.
    #
    # @param e [Ollama::Errors::RequestError | Faraday::ResourceNotFound] the 404 error that occurred.
    def rescue_from(exception, args)
      Rails.logger.warn exception
      Rails.logger.warn "Attempt to pull #{args[:model]} and regenerate."
      messages.pop
      last_message.destroy
      pull_model(model: args[:model])
    end
  end
end
