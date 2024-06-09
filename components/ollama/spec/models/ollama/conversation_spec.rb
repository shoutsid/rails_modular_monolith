# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ollama::Conversation do
  include_examples 'when using component specific Outbox model'

  describe 'associations' do
    it { is_expected.to have_many(:events).with_foreign_key(:ollama_conversation_id) }
    it { is_expected.to have_many(:messages).with_foreign_key(:ollama_conversation_id) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title).on(:update) }
    it { is_expected.to validate_presence_of(:description).on(:update) }
  end
end
