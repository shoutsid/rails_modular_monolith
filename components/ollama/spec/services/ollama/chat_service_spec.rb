# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ollama::ChatService do
  subject { described_class.new(event_payload) }

  let(:event_payload) do
    { conversation_id: 1, messages: [{ role: 'user', content: 'Hello' }], client: 'ollama_controller' }
  end
  let(:client) { class_double(Ollama) }
  let(:conversation) { create(:ollama_conversation) }

  before do
    allow(Ollama).to receive(:new).and_return(client)
    allow(client).to receive(:is_a?).with(any_args).and_return(true)
    allow(Ollama::Conversation).to receive(:find).and_return(conversation)
    allow(Ollama::Conversation).to receive(:create!)
  end

  describe '#initialize' do
    it 'initializes with the correct attributes' do
      expect(subject.event_payload).to eq(event_payload.with_indifferent_access)
      expect(subject.conversation_id).to eq(1)
      expect(subject.send(:messages)).to eq([{ role: 'user', content: 'Hello' }.with_indifferent_access])
      expect(subject.model).to eq(Ollama::Chat::DEFAULT_MODEL)
      expect(subject.client).to eq(client)
    end
  end

  describe '#memoization_and_validation' do
    it 'memoizes all required attributes and raises required exceptions' do
      expect { subject.send(:memoization_and_validation) }.not_to raise_error
    end
  end

  describe '#call' do
    it 'calls the chat service with the provided client, messages, and conversation' do
      expect(Ollama::Chat).to receive(:new).with(hash_including(client:, messages: subject.send(:messages),
                                                                conversation:)).and_call_original
      expect_any_instance_of(Ollama::Chat).to receive(:chat).with(any_args)
      subject.call
    end
  end

  describe '#conversation' do
    it 'retrieves the conversation associated with the current instance' do
      expect(Ollama::Conversation).to receive(:find).with(1)
      subject.send(:conversation)
    end
  end

  describe '#messages' do
    it 'retrieves the messages associated with the current instance' do
      expect(subject.send(:messages)).to eq([{ role: 'user', content: 'Hello' }.with_indifferent_access])
    end
  end

  describe '#validate!' do
    it 'raises an error if the messages are not an array' do
      expect { subject.send(:validate!, 'not an array') }.to raise_error(Ollama::MessagesInvalidError)
    end

    it 'raises an error if the messages do not have the correct structure' do
      expect { subject.send(:validate!, [{ role: 'user' }]) }.to raise_error(Ollama::MessagesInvalidError)
    end
  end

  describe '#messages_is_array?' do
    it 'returns true if messages are an array' do
      expect(subject.send(:messages_is_array?, [])).to be true
    end

    it 'returns false if messages are not an array' do
      expect(subject.send(:messages_is_array?, 'not an array')).to be false
    end
  end

  describe '#messages_empty?' do
    it 'returns true if messages are an empty array' do
      expect(subject.send(:messages_empty?, [])).to be true
    end

    it 'returns false if messages are not an empty array' do
      expect(subject.send(:messages_empty?, [{ role: 'user', content: 'Hello' }.with_indifferent_access])).to be false
    end
  end

  describe '#messages_valid_structure?' do
    it 'returns true if messages have a valid structure' do
      expect(subject.send(:messages_valid_structure?,
                          [{ role: 'user', content: 'Hello' }.with_indifferent_access])).to be true
    end

    it 'returns false if messages do not have a valid structure' do
      expect(subject.send(:messages_valid_structure?, [{ role: 'user' }.with_indifferent_access])).to be false
    end
  end
end
