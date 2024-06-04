require 'rails_helper'

RSpec.describe Ollama::Chat do
  let(:client) { instance_double(Ollama::Controllers::Client) }
  let(:conversation) { FactoryBot.create(:ollama_conversation) }
  let(:messages) { [instance_double(Hash)] }

  subject { Ollama::Chat.new(client:, messages:, conversation:) }
  before do
    allow(client).to receive(:kind_of?).with(any_args).and_return(true)
  end

  describe '#initialize' do
    it 'initializes with the correct attributes' do
      expect(subject.client).to eq(client)
      expect(subject.messages).to eq(messages)
      expect(subject.conversation).to be_a(Ollama::Conversation)
    end
  end

  describe '#generate' do
    it 'generates a response using the AI model with the given prompt' do
      expect(client).to receive(:generate).with(hash_including(model: 'llama3', prompt: 'hi! please send me a long message'))
      subject.generate
    end
  end

  describe '#chat' do
    it 'chats with the AI model using the given message' do
      expect(client).to receive(:chat).with(hash_including(model: 'llama3', messages: messages))
      subject.chat
    end
  end

  describe '#before' do
    it 'processes the given content before sending it to the AI model' do
      expect(Ollama::Message).to receive(:create!)
      subject.before(content: 'test content')
    end
  end

  describe '#after' do
    it 'processes the response from the AI model after it has been generated' do
      expect(Ollama::Message).to receive(:create!)
      expect(subject).to receive_message_chain(:last_message, :events, :pluck, :map, :join).and_return('Healthy response.')
      subject.after
    end
  end

  describe '#pull_model' do
    it 'pulls the model passed from the AI service' do
      expect(client).to receive(:pull).with(hash_including(name: 'llama3'))
      subject.pull_model
    end
  end

  describe '#create_event' do
    it 'creates an event for the current conversation and message' do
      expect(Ollama::Event).to receive(:create!)
      subject.send(:create_event, {})
    end
  end

  describe '#rescue_from_404' do
    it 'rescues from a 404 error by pulling the llama3 model and regenerating the response' do
      expect(client).to receive(:pull).with(hash_including(name: 'llama3'))
      expect(subject).to receive_message_chain(:last_message, :destroy)
      subject.send(:rescue_from_404, instance_double(Ollama::Errors::RequestError, payload: { model: 'llama3' }))
    end
  end
end
