# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ollama::Event do
  include_examples 'when using component specific Outbox model'

  describe 'associations' do
    it { is_expected.to belong_to(:conversation).with_foreign_key(:ollama_conversation_id) }
    it { is_expected.to belong_to(:message).with_foreign_key(:ollama_message_id) }
  end
end
