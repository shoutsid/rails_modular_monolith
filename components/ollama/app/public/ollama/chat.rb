require 'ollama-ai'

module Ollama
  class Chat
    DEFAULT_MODEL = 'llama3'

    attr_reader :client
    attr_accessor :messages

    def initialize
      @client = Ollama.new(
        credentials: { address: 'http://ollama:11434' },
        options: { server_sent_events: true }
      )

      @messages = []
      @conversation = Ollama::Conversation.create!
      @event_callback = lambda do |event, raw|
        create_event(event)
      end
    end

    def pull_llama3
      @client.pull({ name: 'llama3' }) do |event, raw|
        print '.'
      end
    end

    def create_event(event)
      Ollama::Event.create!(data: event, conversation: @conversation, message: @last_message)
    end

    def before(content:)
      @last_message = Ollama::Message.create!(role: 'user', content: content, conversation: @conversation)
      messages << { role: 'user', content: content}
    end

    def after
      complete_response = @last_message.events.pluck(:data).map{|e|
       content = e.dig('message', 'content')
       content ? content : (e.dig('response') || '')
      }.join
      @last_message = Ollama::Message.create!(role: 'assistant', content: complete_response, conversation: @conversation)
      messages << { role: 'assistant', content: complete_response }
    end

    def rescue_from_404(e)
      Rails.logger.warn e
      Rails.logger.warn "Attempt to pull llama3 and regenerate."
      messages.pop
      @last_message.destroy
      pull_llama3
      generate(**e.payload)
    end

    def generate(model: DEFAULT_MODEL, prompt: 'hi! please send me a long message')
      before(content: prompt)
      client.generate({model:, prompt:}, &@event_callback)
      after
    rescue Ollama::Errors::RequestError => e
      if e.detailed_message.include?('status 404')
        rescue_from_404(e)
      else
        raise e
      end
    end

    def chat(model: DEFAULT_MODEL, message: 'hi! please send me a long message')
      before(content: message)
      client.chat({model: model, messages: messages}, &@event_callback)
      after
    rescue Ollama::Errors::RequestError => e
      if e.detailed_message.include?('status 404')
        rescue_from_404(e)
      else
        raise e
      end
    end
  end
end
