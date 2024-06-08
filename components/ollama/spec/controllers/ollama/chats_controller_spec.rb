# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ollama::ChatsController do
  describe '#index' do
    it 'renders the JSON response with all conversations' do
      conversations = create_list(:ollama_conversation, 2)
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(conversations.to_json)
    end
  end

  describe '#show' do
    let(:conversation) { create(:ollama_conversation) }

    it 'renders the JSON response with the conversation' do
      get :show, params: { id: conversation.id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(conversation.to_json)
    end
  end

  describe '#new' do
    let(:conversation) { build(:ollama_conversation) }

    it 'renders the JSON response with a new conversation' do
      get :new
      expect(response).to have_http_status(:created)
      expect(response.body).to eq({ 'conversation' => conversation }.to_json)
    end
  end

  describe '#create' do
    context 'when conversation is created successfully' do
      let(:conversation) { build(:ollama_conversation, title: 'Test Conversation', description: 'Test Description') }
      let(:user_send_messages) do
        [
          { role: 'system', content: 'You are a helpful assistant.' },
          { role: 'user', content: 'What is 4+4?' }
        ]
      end
      let(:chat_return) { [{ role: 'assistant', content: '4+4 is 8' }] + user_send_messages }

      before do
        allow_any_instance_of(Ollama::ChatService).to receive(:call).and_return(chat_return)
      end

      it 'renders the JSON response' do
        expect(Ollama::ChatService).to receive(:new).with(hash_including(model: 'llama3')).and_call_original
        post :create, params: { conversation: conversation.attributes.merge({ messages: user_send_messages }) }
        expect(response).to have_http_status(:created)
        expect(response.body).to eq(chat_return.to_json)
      end

      context 'when requesting from a specific model' do
        it 'renders the JSON response' do
          expect(Ollama::ChatService).to receive(:new).with(hash_including(model: 'starcoder')).and_call_original
          post :create,
               params: { conversation: conversation.attributes.merge({ messages: user_send_messages,
                                                                       model: 'starcoder' }) }
          expect(response).to have_http_status(:created)
          expect(response.body).to eq(chat_return.to_json)
        end
      end
    end

    context 'when conversation creation fails' do
      it 'renders the error response with validation errors' do
        allow(Ollama::Conversation).to receive(:create!) { raise ActiveRecord::RecordInvalid }
        post :create, params: { conversation: {}, messages: [] }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq({ errors: { base: ['Record invalid'] } }.to_json)
      end
    end
  end

  describe '#update' do
    let(:conversation) { create(:ollama_conversation) }

    context 'when conversation update succeeds' do
      it 'renders the JSON response with the updated conversation' do
        patch :update,
              params: { id: conversation.id,
                        conversation: { title: 'Updated Title', description: 'Updated Description' } }
        expect(response).to have_http_status(:ok)
        expect(conversation.reload.title).to eq('Updated Title')
      end
    end

    context 'when conversation update fails' do
      it 'renders the error response with validation errors' do
        patch :update, params: { id: conversation.id, conversation: { title: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq({ errors: { title: ["can't be blank"], description: ["can't be blank"] } }.to_json)
      end
    end
  end

  describe '#destroy' do
    let!(:conversation) { create(:ollama_conversation) }

    it 'renders the JSON response with a success message' do
      delete :destroy, params: { id: conversation.id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq({ 'message' => 'Chat was successfully destroyed.' }.to_json)
    end
  end
end
