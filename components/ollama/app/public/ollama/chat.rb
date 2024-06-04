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

  class Chat
    DEFAULT_MODEL = 'llama3'

    # The Chat class handles generating responses using the AI model.
    attr_reader :client, :conversation, :event_callback
    attr_accessor :messages, :last_message

    # Initializes a new instance of the Chat class.
    #
    # @param client [Ollama::Controllers::Client | Langchain::LLM::Ollama] the AI client to use for generating responses.
    # @param messages [Array<Hash>] the messages in the conversation.
    # @param conversation [Ollama::Conversation] the conversation object associated with the chat.
    def initialize(client:, messages:, conversation:)
      @client, @messages, @conversation, = client, messages, conversation
      @event_callback = event_callback
    end

    def event_callback
      if ollama_controller_client?
        ollama_controller_client_callback
      elsif client.kind_of?(Langchain::LLM::Ollama)
        langchain_event_callback
      else
        raise InvalidClient, 'the client provided is not of type Ollama::Controllers::Client or Langchain::LLM::Ollama'
      end
    end

    def ollama_controller_client_callback
      lambda do |event, _raw|
        create_event(**event)
        raise InvalidRoleError, event.dig('error') if !!event.dig('error') && event.dig('error').include?('invalid role')
      end
    end

    def langchain_event_callback
      lambda do |langchain_event|
        event = langchain_event.raw_response
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
      args = {model:, prompt:}
      if ollama_controller_client?
        client.generate(args, &event_callback)
      else
        client.generate(**args, &event_callback)
      end
      after
    rescue Ollama::Errors::RequestError, Faraday::ResourceNotFound => e
      if e.detailed_message.include?('status 404')
        rescue_from_404(e, args)
        retry
      else
        raise e
      end
    end

    def ollama_controller_client?
      client.kind_of?(Ollama::Controllers::Client)
    end

    # Chats with the AI model using the given message.
    #
    # @param model [String] the AI model to use for generating the response.
    # @param message [String] the message to send to the AI model.
    def chat(model: DEFAULT_MODEL, message: 'hi! please send me a long message')
      before(content: message)
      args = {model:, messages:}
      if ollama_controller_client?
        client.chat(args, &event_callback)
      else
        client.chat(**args, &event_callback)
      end
      after
    rescue Ollama::Errors::RequestError, Faraday::ResourceNotFound => e
      if e.detailed_message.include?('status 404')
        rescue_from_404(e, args)
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
      # Skip pulling a new model in test env.
      # We fall back to a safe client controller that we can pull from. Bypassing any that is passed.
      # At the time of implimentation of the pull endpoint Langchainrb does not include this feature.
      # Possible PR?
      #
      # https://github.com/patterns-ai-core/langchainrb/blob/main/lib/langchain/llm/ollama.rb
      # TODO: Use ENV here for client url
      unless Rails.env.test?
        _client = Ollama.new(credentials: { address: 'http://ollama:11434' }, options: { server_sent_events: true })
        _client.pull({ name: model }) do |event, raw|
          raise InvalidModelError if !!event.dig('error') && event.dig('error').include?('file does not exist')
          print '.'
        end
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
    def rescue_from_404(e, args)
      Rails.logger.warn e
      Rails.logger.warn "Attempt to pull #{args[:model]} and regenerate."
      messages.pop
      last_message.destroy
      pull_model(model: args[:model])
    end
  end
end
