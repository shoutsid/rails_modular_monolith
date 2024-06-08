# frozen_string_literal: true

module Ollama
  # Chats Controller
  class ChatsController < ApplicationController
    def index
      render json: Conversation.all, status: :ok
    end

    def show
      conversation = Conversation.find(params[:id])
      render json: conversation, status: :ok
    end

    def new
      @conversation = Conversation.new
      render json: { conversation: @conversation }, status: :created
    end

    def create
      Conversation.transaction do
        conversation = Conversation.create!(conversation_params.except(:messages, :model))
        payload = { conversation_id: conversation.id, messages: conversation_params.fetch('messages', []),
                    model: conversation_params.fetch('model', 'llama3') }
        chat_service = Ollama::ChatService.new(payload)
        render json: chat_service.call.to_json, status: :created
      end
    end

    def update
      @conversation = Conversation.find(params[:id])
      if @conversation.update(conversation_params)
        render json: { conversation: @conversation, message: 'Chat was successfully updated.' }, status: :ok
      else
        render json: { errors: @conversation.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @conversation = Conversation.find(params[:id])
      if @conversation.destroy
        render json: { message: 'Chat was successfully destroyed.' }, status: :ok
      else
        render json: { errors: @conversation.errors }, status: :unprocessable_entity
      end
    end

    private

    def conversation_params
      params.fetch(:conversation, {}).permit(:title, :description, :model, messages: %i[role content])
    end
  end
end
