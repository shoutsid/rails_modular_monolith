# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ollama::Message do
  include_examples 'when using component specific Outbox model'

  describe 'associations' do
    it {
      expect(subject).to belong_to(:conversation).class_name('Ollama::Conversation').with_foreign_key(:ollama_conversation_id)
    }

    it { is_expected.to have_many(:events).class_name('Ollama::Event').with_foreign_key(:ollama_message_id) }

    it {
      expect(subject).to have_many(:chunks_messages).class_name('Ollama::ChunksMessage').with_foreign_key(:ollama_message_id)
    }

    it { is_expected.to have_many(:chunks).class_name('Ollama::Chunk').through(:chunks_messages) }
  end

  it {
    expect(subject).to define_enum_for(:role).with_values(system: 'system', assistant: 'assistant',
                                                          user: 'user').backed_by_column_of_type(:enum)
  }

  context 'after_create' do
    subject { create(:ollama_message) }

    it 'creates chunks association and send sync embedding event' do
      expect { subject }.to create_outbox_record(Ollama::Outbox).with_attributes lambda {
        {
          'event' => Ollama::Events::SYNC_EMBEDDING,
          'aggregate' => 'Ollama::Chunk'
        }
      }
    end
  end

  context 'after_update' do
    let!(:message) { create(:ollama_message, content: 'hey :D') }

    it 'creates a new chunk association and send sync embedding event' do
      expect_any_instance_of(Ollama::Chunk).to receive(:save!)
        .with(outbox_event: Ollama::Events::SYNC_EMBEDDING).and_call_original

      expect { message.update(content: 'Hi') }.to create_outbox_record(Ollama::Outbox).with_attributes(lambda {
        {
          'event' => Ollama::Events::SYNC_EMBEDDING,
          'aggregate' => 'Ollama::Chunk'
        }
      })
    end
  end
end
