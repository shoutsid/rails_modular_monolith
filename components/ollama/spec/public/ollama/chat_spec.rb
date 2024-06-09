# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ollama::Chat do
  subject { described_class.new(client:, messages:, conversation:) }

  let(:client) { instance_double(Ollama::Controllers::Client) }
  let(:conversation) { create(:ollama_conversation) }
  let(:messages) { [instance_double(Hash)] }

  before do
    allow(client).to receive(:is_a?).with(any_args).and_return(true)
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
      expect(client).to receive(:generate).with(hash_including(model: 'llama3',
                                                               prompt: 'hi! please send me a long message'))
      subject.generate
    end
  end

  describe '#chat' do
    it 'chats with the AI model using the given message' do
      expect(client).to receive(:chat).with(hash_including(model: 'llama3', messages:))
      subject.chat
    end
  end

  describe '#before' do
    it 'processes the given content before sending it to the AI model' do
      expect(Ollama::Message).to receive_message_chain(:new, :save!).with(
        hash_including(outbox_event: Ollama::Events::START_CHAT)
      )
      subject.before(content: 'test content')
    end
  end

  describe '#after' do
    it 'processes the response from the AI model after it has been generated' do
      allow(subject).to receive_message_chain(:last_message, :events, :pluck, :map,
                                               :join).and_return('Healthy response.')
      response_message = instance_double(Ollama::Message)
      expect(Ollama::Message).to receive(:new).and_return(response_message)
      expect(subject).to receive_message_chain(:last_message, :save!).with(
        hash_including(outbox_event: Ollama::Events::STOP_CHAT)
       )
      subject.after
    end
  end

  describe '#pull_model' do
    it 'pulls the model passed from the AI service' do
      expect(client).not_to receive(:pull).with(hash_including(name: 'llama3'))
      subject.pull_model

      allow(Rails).to receive_message_chain(:env, :test?).and_return(true)
      dd = instance_double(Ollama::Controllers::Client)
      allow(Ollama).to receive(:new).with(any_args).and_return(dd)
      allow(dd).to receive(:pull)
      subject.pull_model
    end
  end

  describe '#create_event' do
    it 'creates an event for the current conversation and message' do
      expect(Ollama::Event).to receive(:create!)
      subject.send(:create_event, {})
    end
  end

  describe '#rescue_from' do
    it 'rescues from a error by pulling the llama3 model and regenerating the response' do
      expect(subject).to receive(:pull_model).with(hash_including(model: 'llama3'))
      expect(subject).to receive_message_chain(:last_message, :destroy)
      subject.send(:rescue_from, instance_double(Ollama::Errors::RequestError, payload: { model: 'llama3' }),
                   { model: 'llama3' })
    end
  end
end
