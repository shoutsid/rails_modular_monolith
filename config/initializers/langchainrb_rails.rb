# frozen_string_literal: true

LangchainrbRails.configure do |config|
  config.vectorsearch = Langchain::Vectorsearch::Pgvector.new(
    llm: Langchain::LLM::Ollama.new(url: 'http://ollama:11434')
  )
end
