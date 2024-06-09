# frozen_string_literal: true

FactoryBot.define do
  factory :ollama_chunk, class: 'Ollama::Chunk' do
    data { 'This is a text string' }
    embedding { nil }
  end
end
