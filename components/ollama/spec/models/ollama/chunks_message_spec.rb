# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ollama::ChunksMessage do
  describe 'associations' do
    it { is_expected.to belong_to(:ollama_chunk).class_name('Ollama::Chunk') }
    it { is_expected.to belong_to(:ollama_message).class_name('Ollama::Message') }
  end
end
