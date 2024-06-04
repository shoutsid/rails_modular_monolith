require 'ollama-ai'

module Ollama
  class InvalidModelError < StandardError
    # Custom error class raised when models are invalid
  end

  class InvalidRoleError < StandardError
    # Custom error class raised when message roles are invalid
  end

  class Chat
    DEFAULT_MODEL = 'llama3'

    # The Chat class handles generating responses using the AI model.
    attr_reader :client, :conversation, :event_callback
    attr_accessor :messages, :last_message

    # Initializes a new instance of the Chat class.
    #
    # @param client [Ollama::Controllers::Client] the AI client to use for generating responses.
    # @param messages [Array<Hash>] the messages in the conversation.
    # @param conversation [Ollama::Conversation] the conversation object associated with the chat.
    def initialize(client:, messages:, conversation:)
      @client, @messages, @conversation, = client, messages, conversation
      @event_callback = event_callback
    end

    def event_callback
      lambda do |event, _raw|
        create_event(event)
        raise InvalidRoleError, event.dig('error') if !!event.dig('error') && event.dig('error').include?('invalid role')
      end
    end

    # Generates a response using the AI model with the given prompt.
    #
    # @param model [String] the AI model to use for generating the response.
    # @param prompt [String] the prompt to generate a response for.
    def generate(model: DEFAULT_MODEL, prompt: 'hi! please send me a long message')
      before(content: prompt)
      client.generate({model:, prompt:}, &event_callback)
      after
    rescue Ollama::Errors::RequestError => e
      if e.detailed_message.include?('status 404')
        rescue_from_404(e)
        retry
      else
        raise e
      end
    end

    # Chats with the AI model using the given message.
    #
    # @param model [String] the AI model to use for generating the response.
    # @param message [String] the message to send to the AI model.
    def chat(model: DEFAULT_MODEL, message: 'hi! please send me a long message')
      before(content: message)
      client.chat({model:, messages:}, &event_callback)
      after
    rescue Ollama::Errors::RequestError => e
      if e.detailed_message.include?('status 404')
        rescue_from_404(e)
        retry
      else
        raise e
      end
    end

    # Processes the given content before sending it to the AI model.
    #
    # @param content [String] the content to process.
    def before(content:)
      self.last_message = Ollama::Message.create!(role: 'user', content:, conversation:)
      messages << { role: 'user', content: }
    end

    # Processes the response from the AI model after it has been generated.
    def after
      complete_response = last_message&.events&.pluck(:data)&.map{|e|
       content = e.dig('message', 'content')
       content ? content : (e.dig('response') || '')
      }&.join
      self.last_message = Ollama::Message.create!(role: 'assistant', content: complete_response, conversation: )
      messages << { role: 'assistant', content: complete_response }
    end

    # Pulls the model passed from the AI service.
    # Otherwsie, uses the default model.
    # @param model [String] the AI model to use for generating the response.
    def pull_model(model: DEFAULT_MODEL)
      client.pull({ name: model }) do |event, raw|
        raise InvalidModelError if !!event.dig('error') && event.dig('error').include?('file does not exist')
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
    # @param e [Ollama::Errors::RequestError] the 404 error that occurred.
    def rescue_from_404(e)
      Rails.logger.warn e
      Rails.logger.warn "Attempt to pull #{e.payload.dig(:model)} and regenerate."
      messages.pop
      last_message.destroy
      pull_model(model: e.payload.dig(:model))
    end
  end
end
