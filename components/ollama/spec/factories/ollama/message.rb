# frozen_string_literal: true

FactoryBot.define do
  factory :ollama_message, class: 'Ollama::Message' do
    # https://thoughtbot.github.io/factory_bot/traits/enum.html
    traits_for_enum(:role)
    content { Faker::Lorem.paragraphs(number: 2) }
    association(:conversation, factory: :ollama_conversation)
  end
end
